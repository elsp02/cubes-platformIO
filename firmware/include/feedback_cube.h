// feedback funktionen für bricks
/// nur für bricks

#include "wire_bus.h"

#include <stdint.h> // defines fixed-width integer types and limits in C

// ----------------------------------------------------------
// brick checks if own ID is integrated in payload and sends it to detected children
// ----------------------------------------------------------

bool feedback_contains_own_id(const uint8_t *payload, uint8_t len);

bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len);

