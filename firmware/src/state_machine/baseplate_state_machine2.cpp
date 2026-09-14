// =====================================================================
// baseplate_state_machine2.cpp
// - baseplate main loop as an explicit state machine, PC-controlled
// - build_src_filter of env:uart_baseplate_state_machine in platformio.ini
//
// Sequence (states, in order):
// 1. IDLE               - wait for PC_CMD_START
// 2. DETECTION_INIT      - check for stop, release lines, prepare a cycle
// 3. DETECTING            - poll_child() every child port (handle_detection)
// 4. BUILD_PAYLOAD        - concatenate child payloads into one PC payload
// 5. SEND_PAYLOAD_TO_PC   - send the payload frame to the PC
// 6. GET_INFO_FROM_PC     - wait for the PC's reply (feedback/stop/bad)
// 7. RELAY_FEEDBACK       - relay the feedback frame to every child
// 8. SEND_RESULT_TO_PC    - report PC_RESP_DONE/PC_RESP_FB_FAILED
// 9. READY_NEXT_CYCLE      - back to DETECTION_INIT
//    STOPPING             - run the stop sequence, back to IDLE
// =====================================================================

#include <Arduino.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "detection.h"
#include "pc_communication.h"
#include "feedback.h"
#include "cube_hardware.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;

static uint8_t pc_reply_retry_count = 0; //retry counts if pc replied with bullshit/error after baseplate sends feedback


static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle

// final payload built by build_payload(), sent to the PC by send_payload_to_pc()
static uint8_t payload[MAX_PAYLOAD_LEN]= {0};
static uint8_t payload_len = 0;

// feedback payload received from pc (read_pc_reply)
static uint8_t fb_payload[MAX_PAYLOAD_LEN] = {0};
static uint8_t fb_payload_len = 0;

//---------------------------------------------------
// FEEDBACK
//--------------------------------------------------

// outcome of relay_feedback_to_children() — a domain-level result, distinct from the PC_RESP_* wire bytes
// -> SEND_RESULT_TO_PC is where that translation happens
enum received_feedback_t : uint8_t {
    FB_DONE, //baseplate receives ACK_FINISHED from first brick 
    FB_FAILED   //baseplate receives ACK_FAILED from first brick 
};

// relay_feedback_to_children
// - relays one FEEDBACK FRAME NODE_ID | LED_STATE to every port/child that
//   answered during detection this cycle (child_done[])
//
// retry logic: 
// every such port gets up to CHILD_RETRIES attempts, retrying
// only the ports that haven't confirmed yet each round
//
// - FB_DONE if every present valid child confirmed, FB_FAILED otherwise
static received_feedback_t relay_feedback_to_children(
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


            // relay one feedback frame to every port that had a valid child this cycle (children which sent a valid DATA FRAME)
            if (!child_done[child]) {
                continue;   // no valid child on this port
            }

            if (feedback_done[child]) {
                continue;   // child already confirmed
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

    return all_done ? FB_DONE : FB_FAILED;
}

//---------------------------------------------------
// END SEQUENCE
//--------------------------------------------------

// run_stop_sequence
// - sends an empty payload frame to all connected bricks 
// -> every brick turns its LED off because its ID is missing in the FEEDBACK PAYLOAD 
static void run_stop_sequence(void)
{
    static const uint8_t empty_payload[1] = { 0 };  // never read at len 0

    relay_feedback_to_children(empty_payload, 0);
    //detection_running = false;
}

// state definition
enum class State : uint8_t {
    IDLE,
    DETECTION_INIT,
    DETECTING,
    BUILD_PAYLOAD,
    SEND_PAYLOAD_TO_PC,
    SEND_RESULT_TO_PC,
    GET_INFO_FROM_PC,
    RELAY_FEEDBACK,
    READY_NEXT_CYCLE,
    STOPPING
};

// success/failure report of one whole detection feedback cycle for pc
enum class PcResult : uint8_t {
    DONE,
    FAILED
};
static PcResult pending_pc_result = PcResult::DONE;

static State current_state = State::IDLE; // current state; advanced by exactly one transition per loop() call
//-----------------------------------

// setup
// - releases all lines and opens the PC serial link
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
    switch (current_state){

    //---------------------------------------------------
    // IDLE
    // - waits for PC_CMD_START from the PC (does nothing else while idle)
    // - once received, presets the heartbeat counter so BUILD_PAYLOAD
    //   sends the very first payload immediately, then starts a cycle
    //--------------------------------------------------
        case State:: IDLE:
        {
            if (pc_start_signal_received()){
                cycles_since_last_send = HEARTBEAT_INTERVAL_CYCLE;
            current_state = State:: DETECTION_INIT;
            }
            break;
        }
    

    //---------------------------------------------------
    // DETECTION_INIT
    // - checks whether the PC already sent PC_CMD_STOP before starting a new cycle
    // -> yes: jumps straight to STOPPING
    // -> no: releases all lines, waits one turnaround, and moves on to DETECTING
    //--------------------------------------------------
        case State:: DETECTION_INIT:
        {
            if (stop_received()){
                current_state = State:: STOPPING;
                SER_PRINT("x");
            }
            else{
                SER_PRINT("x");
                //log_reset();
                //reset_detection_buffers(); brauche ich das?????

                release_all_lines();
                _delay_us(TURNAROUND_US);

                current_state = State:: DETECTING;
            }
            break;
        }

    //---------------------------------------------------
    // DETECTING
    // - runs handle_detection() once: polls every child port with retries
    //   and fills child_payload[]/child_payload_len[]/child_done[]
    // - resets the PC-reply retry counter for the send/reply cycle ahead
    //--------------------------------------------------
        case State:: DETECTING:
        {
            handle_detection(child_payload, child_payload_len, child_done);
            release_all_lines();
            current_state = State:: BUILD_PAYLOAD;
            pc_reply_retry_count = 0; //is this location correct??

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
    case State:: BUILD_PAYLOAD:
    {
        build_payload(payload, payload_len, child_done, child_payload, child_payload_len);
        release_all_lines();
        _delay_us(3*BYTE_US);

        bool changed = payload_changed(payload, payload_len);

        cycles_since_last_send ++;

        if (changed || cycles_since_last_send >= HEARTBEAT_INTERVAL_CYCLE){
            current_state = State:: SEND_PAYLOAD_TO_PC;
        } 
        else{
            current_state = State:: READY_NEXT_CYCLE; // restarts with state DETECTION_INIT
        }
        break;
    }

    //---------------------------------------------------
    // SEND_PAYLOAD_TO_PC
    // - sends the built detection frame to the PC, then waits for its reply
    //--------------------------------------------------
    case State:: SEND_PAYLOAD_TO_PC:{
        send_payload_to_pc(payload, payload_len); 

        current_state = State:: GET_INFO_FROM_PC;
        break;
    }

    //GET_INFO_FROM_PC STATE - after the payload frame was sent
    case State:: GET_INFO_FROM_PC:
    {
        //wait for the PC reply: feedback frame, stop, or timeout
        pc_reply_t pc_reply = read_pc_reply(fb_payload, &fb_payload_len);

        switch(pc_reply){

            // PC sent PC_CMD_STOP instead of a feedback frame -> abandon
            // this cycle's payload and go stop the whole sequence
            case PC_REPLY_STOP:
                SER_PRINT("x");
                remember_sent_payload(payload, payload_len);
                cycles_since_last_send = 0;
                current_state = State::STOPPING;
                break;

            // a valid FEEDBACK FRAME arrived into fb_payload -> relay it to the children next
            case PC_REPLY_FRAME:
                 current_state = State:: RELAY_FEEDBACK;
                 break;
            
            // no reply in time (PC_REPLY_TIMEOUT), or a garbled/invalid frame (PC_REPLY_BAD): resend the same payload, up to
            // MAX_PC_REPLY_RETRIES times before giving up on this cycle
            case PC_REPLY_TIMEOUT:
            case PC_REPLY_BAD:
                while (Serial.available() > 0) {  // drop any stray bytes from the bad/partial frame before retrying
                    Serial.read();
                }

                fb_payload_len = 0; // invalide feedback buffer to prevent stale data being relayed

                if (
                    pc_reply_retry_count <
                    MAX_PC_REPLY_RETRIES
                ) {
                    pc_reply_retry_count++;

                    current_state =
                            State::SEND_PAYLOAD_TO_PC;
                } else {
                    pending_pc_result =
                        PcResult::FAILED;

                    current_state =
                            State::SEND_RESULT_TO_PC;//?????? was mach ich da
                }
                break;
        }
        break;
    }

    //---------------------------------------------------
    // RELAY_FEEDBACK
    // - relays the feedback frame received from the PC (fb_payload) to
    //   every child that answered during detection this cycle
    // -> the outcome (switch) decides what SEND_RESULT_TO_PC reports back to the PC
    //--------------------------------------------------
    case State:: RELAY_FEEDBACK:
    {
        received_feedback_t received_feedback = relay_feedback_to_children(fb_payload, fb_payload_len);

        switch(received_feedback){
            // every present child confirmed the feedback (ACK_FINISHED)
            case FB_DONE:
                pending_pc_result = PcResult:: DONE;
                current_state =
                    State:: SEND_RESULT_TO_PC;
                break;

            // at least one present child never confirmed after all retries
            case FB_FAILED:
                pending_pc_result = PcResult:: FAILED;
                current_state =
                    State:: SEND_RESULT_TO_PC;
                break;
        }
        break;
    }

    //---------------------------------------------------
    // SEND_RESULT_TO_PC
    // - reports PC_RESP_DONE or PC_RESP_FB_FAILED for the feedback that was just relayed
    // - remembers this cycle's payload as "sent"
    // ->  BUILD_PAYLOAD's change check compares against it next cycle, and resets the heartbeat counter
    //--------------------------------------------------
    case State:: SEND_RESULT_TO_PC:
    {
        Serial.write(pending_pc_result == PcResult::DONE ? PC_RESP_DONE : PC_RESP_FB_FAILED);

        remember_sent_payload(payload, payload_len);
        cycles_since_last_send = 0;

        current_state = State:: READY_NEXT_CYCLE;
        break;
    }

    //---------------------------------------------------
    // READY_NEXT_CYCLE
    // - no time delay here - adding one desynchronises the wire timing
    // - immediately loops back to DETECTION_INIT to start the next cycle
    //--------------------------------------------------
    case State:: READY_NEXT_CYCLE:
    {
        //delay(150);   // pacing between detection cycles
        current_state = State:: DETECTION_INIT;
        break;
    } 

    //---------------------------------------------------
    // STOPPING
    // - runs the stop sequence
    // - returns to IDLE to wait for the next PC_CMD_START
    //--------------------------------------------------
    case State:: STOPPING:
    {
        run_stop_sequence();

        current_state = State:: IDLE;
        break;
    }

    //---------------------------------------------------
    // default
    // - current_state somehow holds a value outside the defined State enum
    //   (e.g. SRAM corruption from a brief voltage dip when a brick is
    //   inserted, not severe enough to trigger a clean reset) - without
    //   this, no case matches, loop() does nothing, forever, with no
    //   recovery path (no default = the whole thing needs a power-cycle)
    // -> recover into DETECTION_INIT instead of freezing permanently
    //--------------------------------------------------
    default:
    {
        current_state = State:: DETECTION_INIT;
        break;
    }

}
}

