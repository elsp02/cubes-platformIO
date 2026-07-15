// ============================================================
// UART building sequence - baseplate node
// ATtiny1616
//
// PC-controlled variant of main_baseplate_feedback2.cpp:
//   - idles until the PC sends PC_CMD_START
//   - runs the normal detection sequence
//   - sends the payload frame SYNC | LEN | PAYLOAD | CHECKSUM to the
//     PC (first cycle always, then on change or heartbeat)
//   - waits for the PC feedback byte PC_FB_OK and answers with
//     PC_RESP_DONE (wrong byte: PC_RESP_FB_FAILED, timeout: nothing)
//   - PC_CMD_STOP (as reply or between frames) ends the sequence and
//     returns to idle, waiting for the next PC_CMD_START
//
// Feedback to the cubes (LEDs) is intentionally NOT part of this
// firmware yet. The serial line carries only binary frames and the
// single status bytes - no ASCII debug (log_flush is never called).
// ============================================================

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;
static bool last_child_present[CHILD_COUNT] = { false }; // which ports had a child last cycle -> retry budget
static bool detection_running = false; // set by PC_CMD_START, cleared by PC_CMD_STOP

// ----------------------------------------------------------
// Wire descriptors
// ----------------------------------------------------------

static const wire_t child_0 = { &PORTB, PIN1_bm, 0 };  // PB1 — child port 1 (only child port of baseplate)

static const wire_t *children[CHILD_COUNT] ={
    &child_0,
};

//----------------------------------------------------------
// release all lines
//---------------------------------------------------------
static void release_all_lines(void){
    for (uint8_t line = 0; line < CHILD_COUNT; line ++){
        wire_release(children[line]);
    }
}

// ----------------------------------------------------------
// PC link helpers
// ----------------------------------------------------------

// wait for one byte from the PC, with millis() timeout
static bool wait_for_pc_byte(uint8_t *out, unsigned long timeout_ms)
{
    unsigned long started_waiting = millis();

    while (millis() - started_waiting < timeout_ms) {
        if (Serial.available() > 0) {
            *out = (uint8_t)Serial.read();
            return true;
        }
    }
    return false;
}

// drain the serial input buffer, return true if PC_CMD_STOP was among
// the received bytes (stop between frames)
static bool stop_received(void)
{
    bool stop = false;

    while (Serial.available() > 0) {
        if (Serial.read() == PC_CMD_STOP) {
            stop = true;
        }
    }
    return stop;
}

// ----------------------------------------------------------
// Arduino setup
// ----------------------------------------------------------
void setup()
{
    release_all_lines();

    Serial.begin(115200);
}

// ----------------------------------------------------------
// Main loop
// ----------------------------------------------------------
void loop()
{
    // idle state: wait for PC_CMD_START, ignore everything else
    if (!detection_running) {
        if (Serial.available() == 0) {
            return;
        }
        if (Serial.read() != PC_CMD_START) {
            return;
        }

        while (Serial.available() > 0) {   // start fresh: drop stray bytes
            Serial.read();
        }

        detection_running = true;
        // force a frame in the first cycle of the sequence, even if the
        // tower is unchanged since the last STOP
        cycles_since_last_send = HEARTBEAT_INTERVAL_CYCLE;
        return;
    }

    // stop between frames: PC may send PC_CMD_STOP at any time
    if (stop_received()) {
        detection_running = false;
        return;
    }

    log_reset(); // lib code appends into the log buffer; it is never flushed

    // 0. make sure line is idle / give child time to get back to listening
    wire_release(&child_0);
    _delay_us(TURNAROUND_US);


    // 1. poll child
    uint8_t child_payload[CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
    uint8_t child_payload_len[CHILD_COUNT] = {0};                // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[CHILD_COUNT] = {false};
    bool child_acked[CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt ++){
        bool retry_needed = false; //true if any child still has attempts left after this round

        for (uint8_t child = 0; child < CHILD_COUNT; child ++){

            if (child_done[child]) {
                continue;
            }

            // presence-aware retry budget: a port counts as occupied if it had a child last cycle OR already ACKed this cycle
            // Occupied ports keep the full retries, empty ports get a single attempt.
            // -> attempt_budget specifies the maximum number of attempts a the port is allowed in this detection cycle
            uint8_t attempt_budget = (last_child_present[child] || child_acked[child]) ? CHILD_RETRIES : 1;

            if (attempt >= attempt_budget) {
                continue;
            }

            bool acked = false;

            if (poll_child(
                children[child],
                child_payload[child],
                MAX_CHILD_PAYLOAD_LEN,
                &child_payload_len[child],
                &acked
            )){
                child_done[child] = true; //mark child as done -> no more polling of this child in next attempts
            } else { //retries are needed
                if (acked) {
                    child_acked[child] = true; // present but frame failed -> full retry budget from now on
                    retry_needed = true;
                } else if (attempt + 1 < attempt_budget) { //if child was present in the previous detection loop - then also retry
                    retry_needed = true;
                }
            }
        }
        if (!retry_needed) {
            break;
        }
    }

    // remember which ports had a child this cycle (retry budget)
    for (uint8_t child = 0; child < CHILD_COUNT; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
    }

// payload building
    /*
     * Build own/nodes payload:
     * Payload format: NODE_ID ORIENTATION CHILD_MASK CHILD_PAYLOADS...
     */
    uint8_t payload[MAX_PAYLOAD_LEN]; //final payload to be sent upstream
    uint8_t payload_len = 0;          //length of final payload


    //in a loop add children payloads to the final payload
    for (uint8_t child = 0; child < CHILD_COUNT; child++) {
        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not set the child bit because the payload is not included.

        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
            continue;
        }

        //copy child payload into final payload
        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
            payload[payload_len++] = child_payload[child][j];  //copies stored payload into final payload and increases payload_len for next byte
        }
    }

    release_all_lines();

    _delay_us(3 * BYTE_US);

// if payload changed or heartbeat: send payload frame to PC and run the feedback exchange
    bool changed = payload_changed (payload, payload_len);
    cycles_since_last_send ++;

    if (changed || cycles_since_last_send >= HEARTBEAT_INTERVAL_CYCLE) {

        //send payload frame to pc (empty payload / LEN 0 = nothing detected)
        uint8_t checksum = calc_checksum(payload_len, payload);

        Serial.write(SYNC_BYTE);
        Serial.write(payload_len);
        Serial.write(payload, payload_len);
        Serial.write(checksum);

        //wait for the PC reply: feedback byte, stop, or timeout
        uint8_t reply = 0;

        if (wait_for_pc_byte(&reply, PC_REPLY_TIMEOUT_MS)) {
            if (reply == PC_FB_OK) {
                Serial.write(PC_RESP_DONE);
            } else if (reply == PC_CMD_STOP) {
                detection_running = false; // no response byte; the PC exits after sending STOP
            } else {
                Serial.write(PC_RESP_FB_FAILED);
            }
        }
        // timeout: send nothing, continue with the next cycle

        remember_sent_payload(payload, payload_len);
        cycles_since_last_send = 0;
    }

    delay(150); // pacing between detection cycles (same rhythm as the feedback2 firmware)
}
