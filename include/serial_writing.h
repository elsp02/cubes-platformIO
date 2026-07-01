// Declarations for serial payload tracking helpers
#ifndef SERIAL_WRITING_H
#define SERIAL_WRITING_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

bool payload_changed(const uint8_t *payload, uint8_t payload_len);

void remember_sent_payload(const uint8_t *payload, uint8_t payload_len);

//---------------------------------------------------------
// feedback system
//---------------------------------------------------------
void log_line(const char *msg);
void log_flush(void);

#endif