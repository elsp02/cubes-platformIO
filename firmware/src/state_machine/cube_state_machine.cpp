// =====================================================================
// cube_state_machine.cpp
// - cube (brick) main loop as an explicit state machine
// - build_src_filter of env:uart_cube_state_machine in platformio.ini
//
// Sequence (states, in order):
// 1. ORIENTATION       - one-time: blocking scan for the active upstream line + CMD_STATUS
// 2. IDLE               - wait for CMD_STATUS/CMD_FEEDBACK on the active upstream line
// 3. DETECTION_INIT      - ack busy upstream, prepare a detection cycle
// 4. DETECTING            - poll_child() every child port (handle_detection)
// 5. BUILD_SEND_PAYLOAD   - build own+children payload, send it to the parent
//    FEEDBACK_INIT / RELAY_FEEDBACK - TODO, added later
// =====================================================================

#include <Arduino.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"
#include "feedback_cube.h"
#include "cube_hardware.h"
#include "cube_identity.h"

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
// DETECTION - same as baseplate - zusammenfassen
//--------------------------------------------------

static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle
static bool last_child_present[MAX_CHILD_COUNT] = {false};              // feeds attempt_budget in the next handle_detection() call

// handle_detection
// - polls every child port with retries, using presence-aware retry budgets
// - writes results into child_done[]/child_payload[]/child_payload_len[]
//   and updates last_child_present[] for the next cycle
// (same retry logic as baseplate_state_machine2.cpp's handle_detection())
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

            // attempt budget - see retry logic in handle_detection() doc above
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
            )) {
                SER_PRINTLN("CV");
                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts

            #if defined(CUBE_TYPE_NORMAL)
                // Special case: orientation offset for port 1 (Out2, -Y).
                // Only the normal brick's port 1 has this mounting rotation
                if (i == 1) {
                    child_payload[i][1] =
                        (child_payload[i][1] + 3u) % 4u;
                }
            #endif

            } else {
                if (acked) {
                    child_acked[i] = true; // present but frame failed -> full retry budget from now on
                    retry_needed = true;
                } else if (attempt + 1 < attempt_budget) { //if child was present in the previous detection loop - full retry budget
                    retry_needed = true;
                }
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    // feeds attempt_budget in the next handle_detection() call
    for (uint8_t child = 0; child < child_count; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
    }
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

static const wire_t *active_upstream = nullptr; // orientation line locked in by ORIENTATION, used for every later parent exchange
static uint8_t orientation_mask = 0x00;          // this cube's orientation value, sent as part of its own payload
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
        current_state = State::IDLE;
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
        handle_detection();
        current_state = State::BUILD_SEND_PAYLOAD;
        break;
    }

    //---------------------------------------------------
    // BUILD_SEND_PAYLOAD - irgendwie vlt auch  mit baseplate code vereinen (mithilfe der flags??)
    // - builds this cube's own payload: NODE_ID | ORIENTATION | CHILD_MASK | CHILD_PAYLOADS...
    // - sends it upstream to the parent, then releases the lines for the next cycle
    //--------------------------------------------------
    case State::BUILD_SEND_PAYLOAD:
    {
        uint8_t payload[MAX_PAYLOAD_LEN]; // final payload to be sent upstream
        uint8_t payload_len = 0;          // length of final payload
        uint8_t child_mask = 0x00;        // child_mask to be sent in final payload

        payload[payload_len++] = NODE_ID;
        payload[payload_len++] = orientation_mask;
        payload[payload_len++] = 0x00;  // placeholder for child_mask

        for (uint8_t child = 0; child < child_count; child++) {
            if (!child_done[child]) {  // if child[i] didn't respond, skip it
                continue;
            }

            // if this child payload doesn't fit anymore, skip it and leave its bit unset
            if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
                continue;
            }

            child_mask |= (1 << child);   // set bit for child[i] in child_mask (LSB = child 0)

            for (uint8_t j = 0; j < child_payload_len[child]; j++) {
                payload[payload_len++] = child_payload[child][j];
            }
        }

        payload[2] = child_mask;

        SER_PRINT("CM");
        if ((child_mask & 0b10) == 0) {
            SER_PRINT("0");
        }
        SER_PRINTLN2(child_mask, BIN);

        _delay_us(TURNAROUND_US);
        tx_frame(active_upstream, payload, payload_len);


        // in READY_NEXT_CYCLE
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
