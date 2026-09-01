// ============================================================
// Baseplate state machine - debug/standalone variant
// ATtiny1616
//
// Not PC-controlled: runs the detection + feedback cycle continuously,
// no PC_CMD_START/STOP handshake. Feedback content cycles through the
// predefined LED patterns in feedback.h instead of PC-supplied data.
// Payload is sent either as a binary SYNC|LEN|PAYLOAD|CHECKSUM frame
// (SERIAL_WRITING) or as human-readable hex (print_payload_hex, when
// SERIAL_WRITING is off) - see config.h.
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
#include "feedback.h"
#include "cube_hardware.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;
static bool last_child_present[MAX_CHILD_COUNT] = {false}; // which ports had a child last cycle -> retry budget

static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle

static uint8_t payload[MAX_PAYLOAD_LEN];
static uint8_t payload_len = 0;

static uint8_t feedback_index = 0;   // cycles through predefined_feedback_payload[0..3]

//---------------------------------------------------
// DETECTION
//--------------------------------------------------
static void handle_detection(void)
{
    for (uint8_t i = 0; i < child_count; i++) {
        child_done[i] = false;   // fresh detection cycle
    }

    bool child_acked[MAX_CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
        bool retry_needed = false; //true if any child still has attempts left after this round

        for (uint8_t i = 0; i < child_count; i++) {  //child loop, iterates through children

            if (child_done[i]) {
                continue;
            }

            // presence-aware retry budget: a port counts as occupied if it had a child last cycle OR already ACKed this cycle
            // Occupied ports keep the full retries, empty ports get a single attempt.
            uint8_t attempt_budget = (last_child_present[i] || child_acked[i]) ? CHILD_RETRIES : 1;

            if (attempt >= attempt_budget) {
                continue;
            }

            bool acked = false;

            if (poll_child(
                    children[i],
                    child_payload[i],
                    MAX_CHILD_PAYLOAD_LEN,
                    &child_payload_len[i],
                    &acked
            )){
                SER_PRINTLN("CV");
                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts
            } else {
                if (acked) {
                    child_acked[i] = true; // present but frame failed -> full retry budget from now on
                    retry_needed = true;
                } else if (attempt + 1 < attempt_budget) {
                    retry_needed = true;
                }
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    // for the feedback loop to know which ports to keep giving retries next cycle
    for (uint8_t child = 0; child < child_count; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
    }
}

// ----------------------------------------------------------
// PAYLOAD BUILDING : concatenate this cycle's child payloads into payload[]
// ----------------------------------------------------------
static void build_payload(uint8_t *payload, uint8_t &payload_len)
{
    payload_len = 0;

    for (uint8_t child = 0; child < child_count; child++) {
        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not include it.
        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
            continue;
        }

        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
            payload[payload_len++] = child_payload[child][j];
        }
    }

    release_all_lines();
    _delay_us(3 * BYTE_US);
}

//-----------------------------------------------------------
// payload print - human-readable alternative to the binary frame
//-----------------------------------------------------------
static void print_payload_hex(const uint8_t *payload, uint8_t len)
{
    Serial.print("ordered_payload_len = ");
    Serial.println(len);

    Serial.print("ordered_payload = ");

    for (uint8_t i = 0; i < len; i++) {
        if (payload[i] < 0x10) {
            Serial.print("0");
        }

        Serial.print(payload[i], HEX);

        if (i < len - 1) {
            Serial.print(" ");
        }
    }

    Serial.println();
}

//---------------------------------------------------
// FEEDBACK - predefined patterns, not PC-supplied
//--------------------------------------------------

// relay one predefined feedback pattern to every port that delivered a
// valid frame this cycle (child_done, not last_child_present - a port
// that only ACKed but never completed detection is excluded so a single
// flaky port can't be mistaken for a confirmed cube here either).
static void relay_feedback_to_children(void)
{
    bool feedback_done[MAX_CHILD_COUNT] = { false };

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        bool retry_needed = false;

        for (uint8_t child = 0; child < child_count; child++) {

            if (!child_done[child]) {
                continue;   // no confirmed child on this port
            }

            if (feedback_done[child]) {
                continue;   // already confirmed
            }

            if (send_feedback_to_child(
                    children[child],
                    predefined_feedback_payload[feedback_index],
                    predefined_feedback_payload_len[feedback_index]
            )) {
                SER_PRINTLN("CFA");   // confirmed feedback ack
                feedback_done[child] = true;
            } else {
                retry_needed = true;
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    // note which confirmed children never acked the feedback after all retries
    for (uint8_t child = 0; child < child_count; child++) {
        if (child_done[child] && !feedback_done[child]) {
            SER_PRINTLN("FFA");   // failed feedback ack
        }
    }

    feedback_index++;
    if (feedback_index >= 4) {
        feedback_index = 0;
    }
}

// state definition
enum class State : uint8_t {
    DETECTION_INIT,
    DETECTING,
    BUILD_PAYLOAD,
    SEND_PAYLOAD,
    RELAY_FEEDBACK,
    WAIT_NEXT_CYCLE
};

static State current_state = State::DETECTION_INIT;

void setup()
{
    release_all_lines();
    Serial.begin(115200);
}

void loop()
{
    switch (current_state) {

        //DETECTION_INIT STATE - prepare the detection sequence
        case State::DETECTION_INIT:
        {
            release_all_lines();
            _delay_us(TURNAROUND_US);

            current_state = State::DETECTING;
            break;
        }

        //DETECTING STATE - poll children for tree information
        case State::DETECTING:
        {
            handle_detection();
            current_state = State::BUILD_PAYLOAD;
            break;
        }

        //BUILD_PAYLOAD STATE - accumulates received information from cubes into one payload
        case State::BUILD_PAYLOAD:
        {
            build_payload(payload, payload_len);

            bool changed = payload_changed(payload, payload_len);
            cycles_since_last_send++;

            if (changed || cycles_since_last_send >= HEARTBEAT_INTERVAL_CYCLE) {
                current_state = State::SEND_PAYLOAD;
            } else {
                current_state = State::WAIT_NEXT_CYCLE;
            }
            break;
        }

        //SEND_PAYLOAD STATE - binary frame or human-readable hex, depending on config.h
        case State::SEND_PAYLOAD:
        {
            #if SERIAL_WRITING
                        uint8_t checksum = calc_checksum(payload_len, payload);

                        Serial.write(SYNC_BYTE);
                        Serial.write(payload_len);
                        Serial.write(payload, payload_len);
                        Serial.write(checksum);
            #else
                        print_payload_hex(payload, payload_len);
            #endif
            current_state = State::RELAY_FEEDBACK;
            break;
        }

        //RELAY_FEEDBACK STATE - cycle through the predefined LED patterns
        case State::RELAY_FEEDBACK:
        {
            relay_feedback_to_children();

            remember_sent_payload(payload, payload_len);
            cycles_since_last_send = 0;

            current_state = State::WAIT_NEXT_CYCLE;
            break;
        }

        //WAIT_NEXT_CYCLE STATE - back to the top
        case State::WAIT_NEXT_CYCLE:
        {
            current_state = State::DETECTION_INIT;
            break;
        }
    }
}
