// =====================================================================
// detection.cpp
// - polls a single child port for status and its data frame (poll_child)
// - polls every child port with retries (handle_detection)
// (in baseplate and brick)
// =====================================================================

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "detection.h"
#include "cube_hardware.h"

#include <util/delay.h>

// poll_child
// - polls one child port: CMD_STATUS -> ACK_BUSY -> data frame
// - retries are the caller's job; acked_out tells the caller whether the
//   child was present at all, for its retry-budget decision
bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out)
{
    uint8_t b = 0;

    // to check if a child is definitely present on this port - because if so, full retry round if not, just one polling try
    *acked_out = false;

    /*
     * 1. Send CMD_STATUS to child.
     */
    tx_byte(w, CMD_STATUS);

    wire_release(w);
    _delay_us(BAUD_US);

    /*
     * 2. Wait for ACK_BUSY.
     */
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        SER_PRINTLN("NA");
        return false;
    }

    if (b != ACK_BUSY) {
        SER_PRINTLN("WA");
        return false;
    }

    *acked_out = true;

    SER_PRINT("CA");
    /*
     * 3. ACK received, now wait for childs DATA FRAME.
     */
    if (!rx_frame(
            w,
            data_out,
            max_child_payload_len,
            child_payload_len,
            FRAME_TIMEOUT_US,
            INTER_FRAME_TIMEOUT_US
        )) {
        return false;
    }

    return true;
}

// ----------------------------------------------------------
// handle_detection
// - polls every child port with retries, using presence-aware retry budgets
// - writes results into the caller's child_done[]/child_payload[]/child_payload_len[]
// - last_child_present[] is private to this function: nothing outside
//   handle_detection() ever reads it, it only feeds the next call's attempt_budget
//
// retry logic (attempt budget per port):
// - a port counts as "occupied" if it had
//    -> a child last cycle (last_child_present[i])
//    -> or already answered ACK_BUSY this cycle (child_acked[i])
//    => it gets the full CHILD_RETRIES attempts, since this means a child is physically there
// - a port counts as "unoccupied" if it didn´t sent ACK_BUSY
//   => gets only a single attempt because it´s very likely that no child is physically there
// ----------------------------------------------------------
static bool last_child_present[MAX_CHILD_COUNT] = {false};

void handle_detection(
    uint8_t child_payload[][MAX_CHILD_PAYLOAD_LEN],
    uint8_t *child_payload_len,
    bool *child_done
)
{
    for (uint8_t i = 0; i < child_count; i++) {
        child_done[i] = false;   // fresh detection cycle
    }

    bool child_acked[MAX_CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
        bool retry_needed = false; //true if any child still has attempts left after this round

        for (uint8_t i = 0; i < child_count; i++) {  //child loop, iterates through children
            SER_PRINTLN("RC");

            if (child_done[i]) {
                continue;
            }

            // attempt budget - see retry logic in the function doc above
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

