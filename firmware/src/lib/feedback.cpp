// =====================================================================
// feedback.cpp
// - baseplate-side feedback relay, plus the predefined feedback
//   payloads (used by the baseplate_state_machine_debug env)
// =====================================================================

#include "config.h"
#include "feedback.h"
#include "wire_bus.h"
#include "serial_writing.h"

#include <util/delay.h>

// send_feedback_to_child
// - relays a feedback frame to one child port and waits for it to finish
// - true only on ACK_FINISHED from the child (after its own recursive relay)
// -> mirrors the CMD_STATUS/ACK/DATA_FRAME shape of poll_child, but for feedback
bool send_feedback_to_child(
    const wire_t *w,
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
){
    uint8_t b = 0;

    wire_release(w);
    _delay_us(TURNAROUND_US);

    // 1. Send feedback command == same as in detection sequence (but with CMD_STATUS)
    tx_byte(w, CMD_FEEDBACK);

    wire_release(w);

    // 3. wait for ACK_BUSY == same as in detection sequence
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        SER_PRINTLN("NFA");
        return false;
    }

    if (b != ACK_BUSY) {
        SER_PRINTLN("WFA");
        return false;
    }

    // 3. Send feedback frame
    _delay_us(TURNAROUND_US);
    tx_frame(w, fb_payload, fb_payload_len);
    wire_release(w);



    // 3. Wait for child's recursive feedback relay to finish == comparable with DATA_FRAME from child in detection sequence
    if (!rx_byte(w, &b, FEEDBACK_FINISHED_TIMEOUT_US)) {
        SER_PRINTLN("NFF");   // no feedback finished
        return false;
    }

    wire_release(w);
    switch (b) {
        case ACK_FINISHED:
            SER_PRINTLN("CFF");
            return true;

        case ACK_FAILED:
            SER_PRINTLN("FFF");
            return false;

        default:
            SER_PRINTLN("WFF");
            return false;
    }
}

// ----------------------------------------------------------
// Predefined Feedback Payloads
// - fixed test sequences cycled by the debug/non-PC-controlled state machine (baseplate_state_machine_debug env)
// ----------------------------------------------------------

//predefined feedback payloads
const  uint8_t predefined_feedback_payload[4][FB_MAX_PAYLOAD_LEN] = {
    // Payload 0: only cube A green, B and C off
    { CUBE_A_ID, LED_GREEN },

    // Payload 1: A green, B red, C off
    { CUBE_A_ID, LED_GREEN,
      CUBE_B_ID, LED_RED },

    // Payload 2: all three green
    { CUBE_A_ID, LED_GREEN,
      CUBE_B_ID, LED_GREEN,
      CUBE_C_ID, LED_GREEN },

    // Payload 3: only cube C red, A and B off
    { CUBE_C_ID, LED_RED },
};


// predefined feedback payload length 
const  uint8_t predefined_feedback_payload_len[] = {
    2,
    4,
    6,
    2,
};

