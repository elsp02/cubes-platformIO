// =====================================================================
// serial_writing.h
// - payload-change tracking, building and sending (baseplate: skips resending an unchanged detection frame)
// -> just basplate uses file
// currently not used:
//- buffered debug log, used when SERIAL_DEBUG_END is active (config.h)
// =====================================================================
#ifndef SERIAL_WRITING_H
#define SERIAL_WRITING_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"

bool payload_changed(const uint8_t *payload, uint8_t payload_len);  // true if payload differs from the last one remembered

void remember_sent_payload(const uint8_t *payload, uint8_t payload_len); // stores payload as the new "last sent" baseline

void build_payload( // combines every responded child's payload into one PC-bound payload
    uint8_t *payload,
    uint8_t &payload_len,
    const bool *child_done,
    const uint8_t child_payload[][MAX_CHILD_PAYLOAD_LEN],
    const uint8_t *child_payload_len
);

void send_payload_to_pc(const uint8_t *payload, uint8_t payload_len); // sends the built DATA FRAME with SYNC | LEN | PAYLOAD | CHECKSUM to the PC

//------------------------------
// error message buffer for SERIAL_DEBUG_END
// -> currently not in use somewhere (alternative: SERIAL_DEBUG)
//------------------------------
void log_reset(void);
void log_append(const char *message);
void log_appendln(const char *message);

void log_append(uint32_t value, uint8_t base);
void log_appendln(uint32_t value, uint8_t base);

void log_flush(void);
#endif