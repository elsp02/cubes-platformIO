#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"
#include "cube_hardware.h"

#include <util/delay.h>
// ----------------------------------------------------------
// Poll one child port
// ----------------------------------------------------------

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
     * 3. Wait for ACK_BUSY.
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

    //SER_PRINT("CA");
    /*
     * 4. ACK received, now wait for child data byte.
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
// Detection-cycle state — private to this file. Written by
// handle_detection(), read back by build_payload(). Both are
// called from separate loop() iterations of the baseplate state
// machine, so this can't live on the stack of either function.
// ----------------------------------------------------------
//static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
//static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
//static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle
//
//// ports that had a child last cycle -> retry budget (shared with relay_feedback_to_children)
//bool last_child_present[MAX_CHILD_COUNT] = {false};
//
//// ----------------------------------------------------------
//// for baseplate: poll every child port with retries
//// ----------------------------------------------------------
//void handle_detection(void)
//{
//    for (uint8_t i = 0; i < child_count; i++) {
//        child_done[i] = false;   // fresh detection cycle
//    }
//
//    bool child_acked[MAX_CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed
//
//    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
//        bool retry_needed = false; //true if any child still has attempts left after this round
//
//        for (uint8_t i = 0; i < child_count; i++) {  //child loop, iterates through children
//
//            if (child_done[i]) {
//                continue;
//            }
//
//            // presence-aware retry budget: a port counts as occupied if it had a child last cycle OR already ACKed this cycle
//            // Occupied ports keep the full retries, empty ports get a single attempt.
//            // -> attempt_budget specifies the maximum number of attempts a the port is allowed in this detection cycle
//            uint8_t attempt_budget = (last_child_present[i] || child_acked[i]) ? CHILD_RETRIES : 1;
//
//            if (attempt >= attempt_budget) {
//                continue;
//            }
//
//            bool acked = false;
//
//            if (poll_child(
//                    children[i],           //with wire/pin of child[i]
//                    child_payload[i],     //and receive and store the payload in child_payloads[i]
//                    MAX_CHILD_PAYLOAD_LEN, //with max length of MAX_CHILD_PAYLOAD_LEN to avoid overflow
//                    &child_payload_len[i], //and stores the received payload length from child[i]
//                    &acked
//            )){
//                SER_PRINTLN("CV");
//                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts
//            } else {
//                if (acked) {
//                    child_acked[i] = true; // present but frame failed -> full retry budget from now on
//                    retry_needed = true;
//                } else if (attempt + 1 < attempt_budget) { //if child was present in the previous detection loop - then also retry
//                    retry_needed = true;
//                }
//            }
//        }
//
//        if (!retry_needed) {
//            break;
//        }
//    }
//
//    // for the feedback state to know at which port to send the feedback frame
//    for (uint8_t child = 0; child < child_count; child++) {
//        last_child_present[child] = child_done[child] || child_acked[child];
//    }
//}

// ----------------------------------------------------------
// for baseplate: concatenate this cycle's child payloads into payload[]
//// ----------------------------------------------------------
//void build_payload(uint8_t *payload, uint8_t &payload_len)
//{
//    payload_len = 0;
//
//    //in a loop add children payloads to the final payload
//    for (uint8_t child = 0; child < child_count; child++) {
//        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
//            continue;
//        }
//
//        // Check whether this child payload still fits. If not, do not include it.
//        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
//            continue;
//        }
//
//        //copy child payload into final payload
//        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
//            payload[payload_len++] = child_payload[child][j];  //copies stored payload into final payload and increases payload_len for next byte
//        }
//    }
//
//    release_all_lines();
//    _delay_us(3 * BYTE_US);
//}
//
//// ----------------------------------------------------------
//// for baseplate: send the built payload frame to the PC
//// ----------------------------------------------------------
//void send_payload_to_pc(const uint8_t *payload, uint8_t payload_len)
//{
//    uint8_t checksum = calc_checksum(payload_len, payload);
//
//    Serial.write(SYNC_BYTE);
//    Serial.write(payload_len);
//    Serial.write(payload, payload_len);
//    Serial.write(checksum);
//}
