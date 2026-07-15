
//do i need them?
#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out);
