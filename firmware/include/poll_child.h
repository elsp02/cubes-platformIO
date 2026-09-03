// =====================================================================
// poll_child.h
// - polls a single child port for status and its data frame,
//   and polls every child port with retries (in baseplate and brick)
// =====================================================================

#ifndef POLL_CHILD_H
#define POLL_CHILD_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"

bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out); // polls one child; caller handles retries

void handle_detection( // polls every child port with retries, using presence-aware retry budgets; shared by baseplate and cube
    uint8_t child_payload[][MAX_CHILD_PAYLOAD_LEN], // out: child_payload[child_index][payload_index] = byte received from child
    uint8_t *child_payload_len,                     // out: length of the payload received from child[i]
    bool *child_done                                // out: child[i] answered with a valid frame this cycle
);

#endif
