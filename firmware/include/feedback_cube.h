// =====================================================================
// feedback_cube.h
// - feedback handling for bricks (cubes only, not used by the baseplate)
// baseplate-side equivalent is feedback.h
// =====================================================================

#include "wire_bus.h"
#include "config.h"

#include <stdint.h>

bool feedback_contains_own_id(const uint8_t *payload, uint8_t len); // sets local LED if own NODE_ID is found in payload
bool feedback_contains_own_id_rgb(const uint8_t *payload, uint8_t len); // same as above, but drives an addressable RGB LED (see led_test.cpp)

bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len); // relays a feedback frame to one child port

// ----------------------------------------------------------
// predefined feedback 
// -> for main_baseplate_feedback2.cpp
// ----------------------------------------------------------
//extern const uint8_t predefined_feedback_payload[4][FB_MAX_PAYLOAD_LEN];
//extern const uint8_t predefined_feedback_payload_len[4];
