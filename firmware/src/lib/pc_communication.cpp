#include "pc_communication.h"

#include "config.h"
#include "wire_bus.h"


#include <util/delay.h>
// ----------------------------------------------------------
// PC link helpers
// ----------------------------------------------------------

// wait for one byte from the PC, with millis() timeout
 bool wait_for_pc_byte(uint8_t *out, unsigned long timeout_ms)
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
 bool stop_received(void)
{
    bool stop = false;

    while (Serial.available() > 0) {
        if (Serial.read() == PC_CMD_STOP) {
            stop = true;
        }
    }
    return stop;
}


// waits for the PC reply and, if it is a feedback frame, reads and
// validates it into fb_payload/fb_payload_len
pc_reply_t read_pc_reply(uint8_t *fb_payload, uint8_t *fb_payload_len)
{
    uint8_t b = 0;

    if (!wait_for_pc_byte(&b, PC_REPLY_TIMEOUT_MS)) {
        return PC_REPLY_TIMEOUT;
    }

    if (b == PC_CMD_STOP) {
        return PC_REPLY_STOP;
    }

    if (b != SYNC_BYTE) {
        return PC_REPLY_BAD;
    }

    // SYNC seen: the rest of the frame follows back-to-back, so only a
    // short gap between bytes is allowed
    uint8_t len = 0;
    if (!wait_for_pc_byte(&len, PC_FRAME_BYTE_TIMEOUT_MS)) {
        return PC_REPLY_BAD;
    }

    if (len > MAX_PAYLOAD_LEN) {
        return PC_REPLY_BAD;
    }

    for (uint8_t i = 0; i < len; i++) {
        if (!wait_for_pc_byte(&fb_payload[i], PC_FRAME_BYTE_TIMEOUT_MS)) {
            return PC_REPLY_BAD;
        }
    }

    uint8_t received_checksum = 0;
    if (!wait_for_pc_byte(&received_checksum, PC_FRAME_BYTE_TIMEOUT_MS)) {
        return PC_REPLY_BAD;
    }

    if (received_checksum != calc_checksum(len, fb_payload)) {
        return PC_REPLY_BAD;
    }

    *fb_payload_len = len;
    return PC_REPLY_FRAME;
}