// feedback weiterleiten
/// grad für beide vlt ändern 
//// in code_improved war send_feedback to child noch in cube und baseplate firmware
#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>
#include "config.h"
#include "wire_bus.h"

// ----------------------------------------------------------
// Global feedback payload table declarations
// ----------------------------------------------------------
#define FB_PAYLOAD_LEN 6

//extern const uint8_t predefined_feedback_payload[FB_PAYLOAD_LEN];

bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len);

extern const uint8_t predefined_feedback_payload[4][FB_MAX_PAYLOAD_LEN];
extern const uint8_t predefined_feedback_payload_len[4];

//extern uint8_t feedback_index;

//send feedback payload
//bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len);

//void apply_feedback_payload(const uint8_t *fb_payload, uint8_t fb_payload_len);