#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>
#include "config.h"

// ----------------------------------------------------------
// Global feedback payload table declarations
// ----------------------------------------------------------
#define FB_PAYLOAD_LEN 2

extern const uint8_t predefined_feedback_payload[FB_PAYLOAD_LEN];

bool is_expected_feedback_payload(const uint8_t *payload, uint8_t len);

//extern const uint8_t feedback_payloads[FEEDBACK_COUNT][FB_MAX_PAYLOAD_LEN];
//extern const uint8_t feedback_payload_lens[FEEDBACK_COUNT];

//extern uint8_t feedback_index;

//send feedback payload
//bool send_feedback_to_child(const wire_t *w, const uint8_t *fb_payload, uint8_t fb_payload_len);

//void apply_feedback_payload(const uint8_t *fb_payload, uint8_t fb_payload_len);