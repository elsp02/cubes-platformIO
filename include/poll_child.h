
//do i need them?
#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

// acked_out: set to true as soon as the child answers ACK_BUSY, even if
// the data frame afterwards fails. Proves a child is present on this port,
// so the caller keeps the full retry budget for it.
bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out);
