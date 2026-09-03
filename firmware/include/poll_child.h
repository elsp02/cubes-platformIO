// =====================================================================
// poll_child.h
// - polls a single child port for status and its data frame
// in baseplate and brick
// =====================================================================

#ifndef POLL_CHILD_H
#define POLL_CHILD_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#include "wire_bus.h"

bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out); // polls one child; caller handles retries

#endif
