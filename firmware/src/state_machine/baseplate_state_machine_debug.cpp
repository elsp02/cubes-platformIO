// =====================================================================
// baseplate_state_machine_debug.cpp
// abbild von baseplate_state_maachine2.cpp aber als debug/standalone:
// -> not PC-controlled: runs the detection + feedback cycle continuously,
//   no PC_CMD_START/STOP handshake
// -> feedback content cycles through the predefined LED patterns in
//   feedback.h instead of PC-supplied data
// - build_src_filter of env:baseplate_state_machine_debug in platformio.ini
//
// Sequence (states, in order):
// 1. DETECTION_INIT - release lines, prepare a cycle
// 2. DETECTING        - poll_child() every child port (handle_detection)
// 3. BUILD_PAYLOAD     - concatenate child payloads into one payload
// 4. SEND_PAYLOAD      - send the payload (binary frame or hex text)
// 5. RELAY_FEEDBACK    - relay the next predefined feedback pattern to every child
// 6. READY_NEXT_CYCLE   - back to DETECTION_INIT
// =====================================================================

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "detection.h"
#include "feedback.h"
#include "cube_hardware.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;

static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle

static uint8_t payload[MAX_PAYLOAD_LEN];
static uint8_t payload_len = 0;

static uint8_t feedback_index = 0;   // cycles through predefined_feedback_payload[0..3]

//---------------------------------------------------
// FEEDBACK - predefined patterns, not PC-supplied
//--------------------------------------------------
// relay_feedback_to_children
// - relays one current predefined_feedback_payload[feedback_index] every port/child that
//   answered during detection this cycle (child_done[])
//
// retry logic: 
// every such port gets up to CHILD_RETRIES attempts, retrying
// only the ports that haven't confirmed yet each round

static void relay_feedback_to_children(void)
{
    bool feedback_done[MAX_CHILD_COUNT] = { false };

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        bool retry_needed = false;

        for (uint8_t child = 0; child < child_count; child++) {

            // relay one feedback frame to every port that had a valid child this cycle (children which sent a valid DATA FRAME)
            if (!child_done[child]) {
                continue;   // no valid child on this port
            }
            
            if (feedback_done[child]) {
                continue;   // child already confirmed
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
    READY_NEXT_CYCLE
};

static State current_state = State::DETECTION_INIT;  // current state; advanced by exactly one transition per loop() call

// setup
// - releases all lines and opens the serial link
void setup()
{
    release_all_lines();
        PORTB.DIRSET = PIN4_bm;

            PORTB.OUTSET = PIN4_bm;
        _delay_us(2*BAUD_US);
        PORTB.OUTCLR = PIN4_bm;
    Serial.begin(115200);
}

// loop
// - runs one state-machine step per call; see the sequence at the top of this file
void loop()
{
    switch (current_state) {

        //---------------------------------------------------
        // DETECTION_INIT
        // - releases all lines, waits one turnaround, and moves on to DETECTING
        //--------------------------------------------------
        case State::DETECTION_INIT:
        {
            release_all_lines();
            _delay_us(TURNAROUND_US);

            current_state = State::DETECTING;
            break;
        }

        //---------------------------------------------------
        // DETECTING
        // - runs handle_detection() once: polls every child port with retries
        //   and fills child_payload[]/child_payload_len[]/child_done[]
        //--------------------------------------------------
        case State::DETECTING:
        {
            handle_detection(child_payload, child_payload_len, child_done);
            current_state = State::BUILD_PAYLOAD;
            break;
        }

    //---------------------------------------------------
    // BUILD_PAYLOAD
    // - links this cycle's child payloads into payload[] via build_payload()
    // - only proceeds to actually send if the payload changed since the
    //   last send, or HEARTBEAT_INTERVAL_CYCLE cycles passed without a
    //   send (keep-alive so the PC knows the link is still up)
    // -> otherwise skips sending this cycle and goes straight to READY_NEXT_CYCLE
    //--------------------------------------------------
        case State::BUILD_PAYLOAD:
        {
            build_payload(payload, payload_len, child_done, child_payload, child_payload_len);
            release_all_lines();
            _delay_us(3*BYTE_US);

            bool changed = payload_changed(payload, payload_len);
            cycles_since_last_send++;

            if (changed || cycles_since_last_send >= HEARTBEAT_INTERVAL_CYCLE) {
                current_state = State::SEND_PAYLOAD;
            } else {
                current_state = State::READY_NEXT_CYCLE;
            }
            break;
        }

        //---------------------------------------------------
        // SEND_PAYLOAD
        // - sends the built payload as a binary frame (SERIAL_WRITING) or as
        //   human-readable hex text (print_payload_hex), depending on config.h
        //--------------------------------------------------
        case State::SEND_PAYLOAD:
        {
            #if SERIAL_WRITING
                        send_payload_to_pc(payload, payload_len);
            #else
                        print_payload_hex(payload, payload_len);
            #endif
            current_state = State::RELAY_FEEDBACK;
            break;
        }

        //---------------------------------------------------
        // RELAY_FEEDBACK
        // - relays the next predefined feedback pattern to every confirmed child
        // - remembers this cycle's payload as "sent" and resets the heartbeat counter
        //--------------------------------------------------
        case State::RELAY_FEEDBACK:
        {
            relay_feedback_to_children();

            remember_sent_payload(payload, payload_len);
            cycles_since_last_send = 0;

            current_state = State::READY_NEXT_CYCLE;
            break;
        }

    //---------------------------------------------------
    // READY_NEXT_CYCLE
    // - no time delay here - adding one desynchronises the wire timing
    // - immediately loops back to DETECTION_INIT to start the next cycle
    //--------------------------------------------------
        case State::READY_NEXT_CYCLE:
        {
            current_state = State::DETECTION_INIT;
            break;
        }
    }
}
