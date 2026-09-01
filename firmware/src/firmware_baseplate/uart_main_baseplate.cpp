// ============================================================
// UART building sequence - baseplate node
// ATtiny1616
//
// PC-controlled variant of main_baseplate_feedback2.cpp:
//   - idles until the PC sends PC_CMD_START
//   - runs the normal detection sequence
//   - sends the payload frame SYNC | LEN | PAYLOAD | CHECKSUM to the
//     PC (first cycle always, then on change or heartbeat)
//   - waits for the PC reply: a FEEDBACK FRAME (same SYNC|LEN|PAYLOAD|
//     CHECKSUM format, payload = [NODE_ID, LED_STATE] pairs computed
//     from the compare result on the PC), relays it to the cubes over
//     the wire bus, and answers PC_RESP_DONE when every present cube
//     confirmed ACK_FINISHED (PC_RESP_FB_FAILED on a bad frame from
//     the PC or a cube that failed after all retries)
//   - PC_CMD_STOP (as reply or between frames) relays an EMPTY
//     feedback frame (no IDs = every cube turns its LED off), ends
//     the sequence and returns to idle, waiting for the next START
//
// The serial line carries only binary frames and the single status
// bytes - no ASCII debug (log_flush is never called).
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
#include "feedback_cube.h"
#include "pc_communication.h"
#include "cube_hardware.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;
static bool last_child_present[MAX_CHILD_COUNT] = { false }; // which ports had a child last cycle -> retry budget
static bool detection_running = false; // set by PC_CMD_START, cleared by PC_CMD_STOP

// ----------------------------------------------------------
// Wire descriptors - in cube_hardware integriert
// ----------------------------------------------------------

//static const wire_t child_0 = { &PORTB, PIN1_bm, 0 };  // PB1 — child port 1 (only child port of baseplate)
//
//static const wire_t *children[CHILD_COUNT] ={
//    &child_0,
//};
//
//----------------------------------------------------------
// release all lines - in cube hardware integriert
//---------------------------------------------------------
//static void release_all_lines(void){
//    for (uint8_t line = 0; line < CHILD_COUNT; line ++){
//        wire_release(children[line]);
//    }
//}

// relay one feedback frame to every port that had a child this cycle,
// with the same retry pattern as the detection polling.
// Returns true if every present child confirmed.
static bool relay_feedback_to_children(
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
)
{
    bool feedback_done[MAX_CHILD_COUNT] = { false };
    bool all_done = true;

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        bool retry_needed = false;
        all_done = true;

        for (uint8_t child = 0; child < child_count; child++) {

            if (!last_child_present[child]) {
                continue;   // no cube on this port
            }

            if (feedback_done[child]) {
                continue;   // already confirmed
            }

            if (send_feedback_to_child(children[child], fb_payload, fb_payload_len)) {
                feedback_done[child] = true;
            } else {
                all_done = false;
                retry_needed = true;
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    return all_done;
}

// stop sequence: every cube turns its LED off when its ID is missing
// from the feedback payload, so an EMPTY frame switches all LEDs off
static void run_stop_sequence(void)
{
    static const uint8_t empty_payload[1] = { 0 };  // never read at len 0

    relay_feedback_to_children(empty_payload, 0);
    detection_running = false;
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
        run_stop_sequence();   // all LEDs off, back to idle
        return;
    }

    log_reset(); // lib code appends into the log buffer; it is never flushed

    //DETECTION SEQUENCE
    // 0. make sure line is idle / give child time to get back to listening
    wire_release(children[0]);
    _delay_us(TURNAROUND_US);


    // 1. poll child
    uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
    uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[MAX_CHILD_COUNT] = {false};
    bool child_acked[MAX_CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt ++){
        bool retry_needed = false; //true if any child still has attempts left after this round

        for (uint8_t child = 0; child < child_count; child ++){

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
    for (uint8_t child = 0; child < child_count; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
    }

// PAYLOAD BUILDING
    /*
     * Build own/nodes payload:
     * Payload format: NODE_ID ORIENTATION CHILD_MASK CHILD_PAYLOADS...
     */
    uint8_t payload[MAX_PAYLOAD_LEN]; //final payload to be sent upstream
    uint8_t payload_len = 0;          //length of final payload


    //in a loop add children payloads to the final payload
    for (uint8_t child = 0; child < child_count; child++) {
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

        //wait for the PC reply: feedback frame, stop, or timeout
        uint8_t fb_payload[MAX_PAYLOAD_LEN];   // MAX_PAYLOAD_LEN, not FB_MAX_PAYLOAD_LEN:
                                               // an unexpected extra cube makes the payload longer
        uint8_t fb_payload_len = 0;

        //switch wertet einen einzelnen wert aus und führt abhängig davon den passenden case block aus
        switch (read_pc_reply(fb_payload, &fb_payload_len)) {

            // FEEDBACK TO CHILDREN
            case PC_REPLY_FRAME:
                // relay the LED states to the cubes; DONE only when every
                // present cube confirmed the frame came back around
                if (relay_feedback_to_children(fb_payload, fb_payload_len)) {
                    Serial.write(PC_RESP_DONE);
                } else {
                    Serial.write(PC_RESP_FB_FAILED);
                }
                break;
            
            //when pc sends an end message -> all leds of and go back to detection running sequence at the beginning
            case PC_REPLY_STOP:
                run_stop_sequence(); // no response byte; the PC exits after sending STOP
                break;
            
            // if pc sends any invalid message (invalid sync byte, len, crc, ...)- tell that PC
            case PC_REPLY_BAD:
                // broken frame from the PC: report it and drop stray bytes
                while (Serial.available() > 0) {
                    Serial.read();
                }
                Serial.write(PC_RESP_FB_FAILED);
                break;
            
            // if nothing arrives from pc
            case PC_REPLY_TIMEOUT:
                // send nothing, continue with the next cycle
                break;
        }

        remember_sent_payload(payload, payload_len);
        cycles_since_last_send = 0;
    }

    delay(550); // pacing between detection cycles (same rhythm as the feedback2 firmware)
}
