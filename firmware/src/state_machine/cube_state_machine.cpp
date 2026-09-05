// =====================================================================
// cube_state_machine.cpp
// - cube (brick) main loop as an explicit state machine
// - build_src_filter of env:uart_cube_state_machine in platformio.ini
//
// Sequence (states):
// 1. ORIENTATION        - one-time: blocking scan for the active upstream line + CMD_STATUS, then -> DETECTION_INIT
// 2. IDLE                - wait for CMD_STATUS/CMD_FEEDBACK on the active upstream line, dispatches to one of the two cycles below
//
//    DETECTION CYCLE (CMD_STATUS):
// 3. DETECTION_INIT       - ack busy upstream, prepare a detection cycle
// 4. DETECTING             - poll_child() every child port (handle_detection)
// 5. BUILD_SEND_PAYLOAD    - build own+children payload, send it to the parent
//
//    FEEDBACK CYCLE (CMD_FEEDBACK):
// 6. FEEDBACK_INIT         - ack busy upstream, receive the feedback frame, apply it to the own LED
// 7. RELAY_FEEDBACK        - relay the feedback frame to every child that answered detection this cycle
//
// 8. READY_NEXT_CYCLE      - release the lines used this cycle, back to IDLE
// =====================================================================

#include <Arduino.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "detection.h"
#include "feedback_cube.h"
#include "cube_hardware.h"

static const wire_t *active_upstream = nullptr; // orientation line locked in by ORIENTATION, used for every later parent exchange
static uint8_t orientation_mask = 0x00;          // this cube's orientation value, sent as part of its own payload

static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle

static uint8_t fb_payload[MAX_PAYLOAD_LEN];   // feedback frame received from the parent in FEEDBACK_INIT, relayed in RELAY_FEEDBACK
static uint8_t fb_payload_len = 0;

//---------------------------------------------------
// ORIENTATION
//--------------------------------------------------

// scan_upstream
// - scans all upstream lines for LOW, returns index of the first LOW line, or -1 if none is LOW
static int8_t scan_upstream(void)
{
    for (uint8_t i = 0; i < upstream_count; i++) {
        if (!is_line_high(&upstream[i])) {
            return (int8_t)i;
        }
    }
    return -1;
}

// wait_for_valid_upstream_cmd
// - blocks until a valid CMD_STATUS frame arrives on some upstream line
// - runs exactly once: the state machine never re-enters ORIENTATION after this
//   returns (unplugging a cube cuts its power, so a stale orientation can't occur)
static void wait_for_valid_upstream_cmd(
    const wire_t **active_line,
    uint8_t *orientation_mask
)
{
    while (true) {
        int8_t ori = scan_upstream(); // detects orientation line - 0/1/2/3 or -1 if no low is detected

        if (ori < 0) {  // if no line is low, repeat orientation scan
            continue;
        }

        const wire_t *w = &upstream[ori];

        uint8_t b = 0;

        if (!rx_byte_frame(w, &b)) { // no valid byte received within timeout
            continue;
        }

        if (b != CMD_STATUS) {
            release_all_lines();
            continue;
        }

        *active_line = w;
        *orientation_mask = (uint8_t)ori;
        return;
    }
}


//---------------------------------------------------
// FEEDBACK
//--------------------------------------------------
// receive_feedback
// - acks the parent's CMD_FEEDBACK with ACK_BUSY, then receives the feedback frame into fb_payload/fb_payload_len
// -> if Receiving failed: sends ACK_FAILED to parent
static bool receive_feedback(void)
{
    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, ACK_BUSY);
    wire_release(active_upstream);

    if (!rx_frame(
            active_upstream,
            fb_payload,
            MAX_PAYLOAD_LEN,
            &fb_payload_len,
            CHILD_TIMEOUT_US,
            INTER_FRAME_TIMEOUT_US
        )) {
        _delay_us(TURNAROUND_US);
        tx_byte(active_upstream, ACK_FAILED); // if rx_frame failed, send ack_failed to parent
        wire_release(active_upstream);
        return false;
    }

    return true;
}

// relay_feedback
// - relays fb_payload to every child that answered during detection this cycle (child_done[]), stopping at the first failure
//
// - sends answer to parent:
// -> if feedback relaying failed: ACK_FAILED
// -> if every present children confirmed: ACK_FINISHED
static bool relay_feedback(void)
{
    bool all_feedback_done = true;

    for (uint8_t child = 0; child < child_count; child++) {  //child loop, iterates through children

        if (!child_done[child]) {
            continue;
        }

        if (!send_feedback_to_child(children[child], fb_payload, fb_payload_len)) {
            all_feedback_done = false;
            break;   // stop relaying to remaining children
        }
    }

    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, all_feedback_done ? ACK_FINISHED : ACK_FAILED);
    wire_release(active_upstream);

    return all_feedback_done;
}

// state definition
enum class State : uint8_t {
    ORIENTATION,
    IDLE,
    DETECTION_INIT,
    DETECTING,
    BUILD_SEND_PAYLOAD,
    FEEDBACK_INIT,
    RELAY_FEEDBACK,
    READY_NEXT_CYCLE
};

static State current_state = State::ORIENTATION; // current state; advanced by exactly one transition per loop() call
//-----------------------------------

// setup
// - releases all lines and opens the debug serial link
void setup()
{
    release_all_lines();

    // Configure LED pins as outputs.
    PORTB.DIRSET = GREEN_LED_PIN | RED_LED_PIN;

    // LEDs initially off.
    PORTB.OUTCLR = GREEN_LED_PIN | RED_LED_PIN;

    Serial.begin(115200);
    Serial.println("cube_state_machine started");
}

// loop
// - runs one state-machine step per call; see the sequence at the top of this file
void loop()
{
    switch (current_state) {

    //---------------------------------------------------
    // ORIENTATION
    // - blocks until a valid CMD_STATUS frame is found on some upstream line
    // - locks that line in as active_upstream for the rest of this cube's lifetime
    //--------------------------------------------------
    case State::ORIENTATION:
    {
        wait_for_valid_upstream_cmd(&active_upstream, &orientation_mask);
        current_state = State::DETECTION_INIT;
        break;
    }

    //---------------------------------------------------
    // IDLE
    // - waits for CMD_STATUS/CMD_FEEDBACK from the parent on active_upstream
    // - times out harmlessly and stays IDLE if nothing arrives in time
    //--------------------------------------------------
    case State::IDLE:
    {
        uint8_t cmd = 0;

        if (!rx_byte(active_upstream, &cmd, PARENT_TIMEOUT_US)) {
            break;  // nothing arrived in time, stay IDLE
        }

        switch (cmd) {
            case CMD_STATUS:
                current_state = State::DETECTION_INIT;
                break;

            case CMD_FEEDBACK:
                current_state = State::FEEDBACK_INIT;
                break;

            default:
                SER_PRINTLN("WC");
                break;  // unrecognized byte, stay IDLE
        }
        break;
    }

    //---------------------------------------------------
    // DETECTION_INIT
    // - acks the parent's CMD_STATUS with ACK_BUSY before polling own children
    //--------------------------------------------------
    case State::DETECTION_INIT:
    {
        _delay_us(TURNAROUND_US);
        tx_byte(active_upstream, ACK_BUSY);
        wire_release(active_upstream);

        current_state = State::DETECTING;
        break;
    }

    //---------------------------------------------------
    // DETECTING
    // - polls every child port with retries, fills child_payload[]/child_payload_len[]/child_done[]
    //--------------------------------------------------
    case State::DETECTING:
    {
        handle_detection(child_payload, child_payload_len, child_done);
        current_state = State::BUILD_SEND_PAYLOAD;
        break;
    }

    //---------------------------------------------------
    // BUILD_SEND_PAYLOAD
    // - builds this cube's own payload: NODE_ID | ORIENTATION | CHILD_MASK | CHILD_PAYLOADS...
    //   via build_payload() (shared with the baseplate, see serial_writing.cpp)
    // - sends it upstream to the parent, then releases the lines for the next cycle
    //--------------------------------------------------
    case State::BUILD_SEND_PAYLOAD:
    {
        uint8_t payload[MAX_PAYLOAD_LEN]; // final payload to be sent upstream
        uint8_t payload_len = 0;          // length of final payload

        build_payload(payload, payload_len, child_done, child_payload, child_payload_len, orientation_mask);

        SER_PRINT("CM");
        if ((payload[2] & 0b10) == 0) {
            SER_PRINT("0");
        }
        SER_PRINTLN2(payload[2], BIN);

        _delay_us(TURNAROUND_US);
        tx_frame(active_upstream, payload, payload_len);
        current_state = State:: READY_NEXT_CYCLE;
        break;

       
    }

    //---------------------------------------------------
    // FEEDBACK_INIT
    // - acks the parent's CMD_FEEDBACK with ACK_BUSY, then receives the feedback frame
    // - applies the frame to this cube's own LED
    // - on failure, ACKs the failure upstream and ends the cycle (no retry)
    //--------------------------------------------------
    case State:: FEEDBACK_INIT:
    {
        if (!receive_feedback()) {
            current_state = State::READY_NEXT_CYCLE;
            break;
        }

        // Apply the frame to the own LED:
        // true  = own ID was in the payload (LED set green/red inside),
        // false = own ID absent -> LED switched off
        if (feedback_contains_own_id_rgb(fb_payload, fb_payload_len)) {
            SER_PRINTLN("FI");  // feedback: own id included
        } else {
            SER_PRINTLN("FO");  // feedback: own id absent, LED off
        }

        current_state = State:: RELAY_FEEDBACK;
        break;
    }

    //---------------------------------------------------
    // RELAY_FEEDBACK
    // - relays the feedback frame to every child that answered during
    //   detection this cycle (child_done[]), stopping at the first failure
    // - sends ACK_FINISHED/ACK_FAILED upstream depending on the outcome
    //--------------------------------------------------
    case State:: RELAY_FEEDBACK:
    {
        relay_feedback();
        current_state = State::READY_NEXT_CYCLE;
        break;
    }

    //---------------------------------------------------
    // READY_NEXT_CYCLE
    // - common funnel for every cycle (DETECTION or FEEDBACK)
    // - loops back to IDLE
    //--------------------------------------------------
    case State::READY_NEXT_CYCLE:
    {
        wire_release(active_upstream);
        release_all_lines();

        #if SERIAL_DEBUG_END
            log_flush();
        #endif

        current_state = State::IDLE;
        break;
    }

    }
}
