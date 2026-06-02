// ============================================================
// Prototype v2_2 - child Node
// ATtiny1616
//
// PlatformIO structure:
//   include/config.h
//   include/wire_bus.h
//   src/wire_bus.cpp
//   src/main.cpp
// ============================================================

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"

// ----------------------------------------------------------
// Wire descriptors
// ----------------------------------------------------------

// Upstream orientation ports.
// Index in this array equals orientation value.
static const wire_t upstream[] = {
    { &PORTA, PIN1_bm, 1 },     // PA1 — orientation 0
    { &PORTA, PIN3_bm, 3 },     // PA3 — orientation 1
    { &PORTA, PIN4_bm, 4 },     // PA4 — orientation 2
    { &PORTA, PIN5_bm, 5 },     // PA5 — orientation 3
};

//suggestion: replace UPSTREAM_COUNT with upstream_count to avoid hardcoding the count
static int upstream_count = sizeof(upstream) / sizeof(upstream[0]);

static const wire_t child_0 = { &PORTB, PIN0_bm, 0 };  // PB0 — child port 0
static const wire_t child_1 = { &PORTB, PIN1_bm, 1 };  // PB1 — child port 1

static const wire_t *children[CHILD_COUNT] = {
    &child_0,
    &child_1
};

// ----------------------------------------------------------
// Fast upstream scan
// ----------------------------------------------------------

static int8_t scan_upstream(void)
{
    for (uint8_t i = 0; i < UPSTREAM_COUNT; i++) {
        if (!line_high(&upstream[i])) {
            return (int8_t)i;
        }
    }

    return -1;
}

// ----------------------------------------------------------
// Wait for upstream command
// ----------------------------------------------------------

static bool wait_for_valid_upstream_cmd(
    const wire_t **active_line,
    uint8_t *orientation
)
{
    while (1) {
        int8_t ori = scan_upstream();

        if (ori < 0) {
            continue;
        }

        const wire_t *w = &upstream[ori];

        uint8_t b = 0;

        if (!rx_byte_after_start_detected(w, &b)) {
            continue;
        }

        if (b != CMD_STATUS) {
            for (uint8_t i = 0; i < UPSTREAM_COUNT; i++) {
                wire_release(&upstream[i]);
            }
            wire_release(&child_0);
            wire_release(&child_1);
            continue;
        }

        *active_line = w;
        *orientation = (uint8_t)ori;

        return true;
    }
}

// ----------------------------------------------------------
// Poll one child port
// ----------------------------------------------------------

static bool poll_child(const wire_t *w, uint8_t *data_out)
{
    uint8_t b = 0;

    /*
     * 1. Send CMD_STATUS to child.
     */
    tx_byte(w, CMD_STATUS);

    /*
     * 2. Switch direction / wait before receiving.
     */
    _delay_us(TURNAROUND_US);
    wire_release(w);

    /*
     * 3. Wait for ACK_BUSY.
     */
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        return false;
    }

    if (b != ACK_BUSY) {
        return false;
    }

    /*
     * 4. ACK received, now wait for child data byte.
     */
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        return false;
    }

    /*
     * 5. Store received data.
     */
    *data_out = b;
    return true;
}

// ----------------------------------------------------------
// Arduino setup
// ----------------------------------------------------------

void setup()
{
    for (uint8_t i = 0; i < UPSTREAM_COUNT; i++) {
    wire_release(&upstream[i]);
    }
    wire_release(&child_0);
    wire_release(&child_1);

    Serial.begin(9600);
    Serial.println("Prototype v2 child started");
}

// ----------------------------------------------------------
// Main loop
// ----------------------------------------------------------

void loop()
{
    /*
     * These variables must be static because orientation detection
     * should only happen once, but the detected active upstream line
     * must still be available in later loop() iterations.
     */
    static bool orientation_known = false;
    static const wire_t *active_upstream = nullptr; //code merkt sich dauerhaft die Orientierungsleitung
    static uint8_t orientation = 0;

    /*
     * 1. Detect orientation only once.
     */
    if (!orientation_known) {
        wait_for_valid_upstream_cmd(&active_upstream, &orientation);
        orientation_known = true;
    }

    /*
     * Safety check.
     * Should normally never be true after orientation_known == true.
     */
    if (active_upstream == nullptr) {
        orientation_known = false;
        return;
    }

    /*
     * 2. Send ACK_BUSY upstream on the detected active line.
     */
    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, ACK_BUSY);
    /*wire_release(active_upstream);

    /*
     * 3. Poll own children with retries.
     */
    uint8_t child_mask = 0x00;
    uint8_t child_data[CHILD_COUNT] = {0};
    bool child_done[CHILD_COUNT] = {false};

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        for (uint8_t i = 0; i < CHILD_COUNT; i++) {

            if (child_done[i]) {
                continue;
            }

            if (poll_child(children[i], &child_data[i])) {
                child_done[i] = true;
                child_mask |= (1 << i);
            }
        }
    }

    /*
     * 4. Print/debug result.
     */
    Serial.print("Final child_mask = 0b");

    if ((child_mask & 0b10) == 0) {
        Serial.print("0");
    }

    Serial.println(child_mask, BIN);

    /*
     * 5. Send predefined DATA_BYTE upstream.
     */
    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, DATA_BYTE);
    wire_release(active_upstream);
    // 5. release all lines
    for (uint8_t i = 0; i < UPSTREAM_COUNT; i++) {
        wire_release(&upstream[i]);
    }
    wire_release(&child_0);
    wire_release(&child_1); 
}