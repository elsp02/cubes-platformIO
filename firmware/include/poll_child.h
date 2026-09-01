#ifndef POLL_CHILD_H
#define POLL_CHILD_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#include "wire_bus.h"

bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out);

// ports that had a responding/ACKed child in the most recent handle_detection() cycle
// (drives the retry-budget decision in handle_detection() and which ports get relay_feedback_to_children())
extern bool last_child_present[];

// poll every child port with retries; caches results internally for build_payload()
//void handle_detection(void);
//
//// copies this cycle's cached child payloads into payload[]; sets payload_len
//void build_payload(uint8_t *payload, uint8_t &payload_len);
//
//// sends the SYNC | LEN | payload | CHECKSUM frame to the PC
//void send_payload_to_pc(const uint8_t *payload, uint8_t payload_len);

#endif
