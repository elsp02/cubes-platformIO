// communication baseplate und pc

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>
#include "config.h"

bool wait_for_pc_byte(uint8_t *out, unsigned long timeout_ms);

bool stop_received(void);

// possible outcomes of waiting for the PC reply after a payload frame
enum pc_reply_t : uint8_t {
    PC_REPLY_TIMEOUT,   // nothing arrived at all
    PC_REPLY_STOP,      // PC_CMD_STOP instead of a feedback frame
    PC_REPLY_FRAME,     // valid feedback frame stored in the buffer
    PC_REPLY_BAD,       // unexpected byte / broken frame / bad checksum
};

pc_reply_t read_pc_reply(uint8_t *fb_payload, uint8_t *fb_payload_len);