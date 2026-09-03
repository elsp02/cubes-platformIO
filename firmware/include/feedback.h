// =====================================================================
// feedback.h
// - feedback relay used by the baseplate side (and debug/predefined
//   feedback sequences)
// - cube-side equivalent is feedback_cube.h
// =====================================================================


#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"


bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len); // relays a feedback frame to one child port

// ----------------------------------------------------------
// predefined feedback 
// -> for main_baseplate_feedback2.cpp
// ----------------------------------------------------------
extern const uint8_t predefined_feedback_payload[4][FB_MAX_PAYLOAD_LEN];
extern const uint8_t predefined_feedback_payload_len[4];

