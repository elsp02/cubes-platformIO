// ============================================================
// Prototype v3 - child Node - not tested yet
// child polling: child wise (first child 1 then next child) -> no need of flat buffer (main_cube.cpp)
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
static const uint8_t upstream_count = sizeof(upstream) / sizeof(upstream[0]);

static const wire_t child_0 = { &PORTB, PIN0_bm, 0 };  // PB0 — child port 0
static const wire_t child_1 = { &PORTB, PIN1_bm, 1 };  // PB1 — child port 1

static const wire_t *children[CHILD_COUNT] = {
    &child_0,
    &child_1
};

// ----------------------------------------------------------
// Release all communication lines
// ----------------------------------------------------------

static void release_all_lines(void)
{
    for (uint8_t i = 0; i < upstream_count; i++) {
        wire_release(&upstream[i]);
    }

    for (uint8_t i = 0; i < CHILD_COUNT; i++) {
        wire_release(children[i]);
    }
}

// ----------------------------------------------------------
// Fast upstream scan
// scans all upstream lines for LOW and returns index of first detected LOW line (orientation value), or -1 if no line is LOW
// ----------------------------------------------------------

static int8_t scan_upstream(void)
{
    for (uint8_t i = 0; i < upstream_count; i++) {
        if (!is_line_high(&upstream[i])) {
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
    uint8_t *orientation_mask
)
{
    while (1) {
        int8_t ori = scan_upstream(); // detects orientation line - 0/1/2/3 or -1 if no low is detected 

        if (ori < 0) {  //if no line is low, repeat orientation scan 
            continue;
        }

        const wire_t *w = &upstream[ori]; //assignment (zuordnung) of detected orientation line/pin to w

        uint8_t b = 0;

        if (!rx_byte_data_frame(w, &b)) { //receiving of message (sent bits) without start bit, false if no valid bits are received within timeout
            continue;
        }

        //checks if received byte is CMD_STATUS, if not, repeat orientation scan and go into loop
        if (b != CMD_STATUS) {  
            for (uint8_t i = 0; i < upstream_count; i++) { //release all upstream lines
                wire_release(&upstream[i]);
            }
            wire_release(&child_0); //release child lines, just in case
            wire_release(&child_1); //release child lines, just in case
            continue;
        }
        
        // if correct CMD_STATUS is received, ausgabeparameter aus funktion: assign detected line to active_line and orientation value to orientation and return true
        *active_line = w;
        *orientation_mask = (uint8_t)ori;

        return true;
    }
}

// ----------------------------------------------------------
// Poll one child port
// ----------------------------------------------------------

static bool poll_child(
    const wire_t *w,
    uint8_t *child_payload,
    uint8_t max_child_payload_len,
    uint8_t *child_payload_len
)
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
    // wire_release(w);  redundant

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
     * 4. ACK received, now receive full DATA_FRAME.
     *    rx_frame validates SYNC, LEN and CHECKSUM.
     *    It returns only the child payload.
     */
    if (!rx_frame(
            w,
            child_payload,
            max_child_payload_len,
            child_payload_len,
            FRAME_TIMEOUT_US
        )) {
        return false;
    }

    return true;
}

// ----------------------------------------------------------
// Arduino setup
// ----------------------------------------------------------

void setup()
{
    release_all_lines();

    Serial.begin(9600);
    Serial.println("Prototype v3 recursive node started");
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
    static uint8_t orientation_mask = 0x00; //orientation mask,now 1 byte, later combined with child_mask to one byte 
    /// create variables (LEN_gesamt, LEN_Loop child etc.)

    /*
     * 1. Detect orientation only once.
     */
    if (!orientation_known) {
        wait_for_valid_upstream_cmd(&active_upstream, &orientation_mask); // selects active upstream line and orientation value (orientation value must be transformed to orientation_byte for sending )
        orientation_known = true;
    }  else {
        // if orientation is already known, no need to check orientation just receive CMD_STATUS
        uint8_t b = 0;

        if (!rx_byte(active_upstream, &b, PARENT_TIMEOUT_US)) {
            Serial.println("Timeout: no byte received");
            return;
        }

        if (b != CMD_STATUS) {
            Serial.println("Unexpected byte received");
            return;
        }
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
    //wire_release(active_upstream);

     /*
     * 3. Poll own children with retries -> one after another to avoid flat buffer
     */
    uint8_t payload[MAX_PAYLOAD_LEN];
    uint8_t payload_len = 0;
    uint8_t child_mask = 0x00;

    // Own node data first
    payload[payload_len++] = NODE_ID;
    payload[payload_len++] = orientation_mask;
    payload[payload_len++] = 0x00;   // placeholder for child_mask

    // Poll children (and add its payload) one after another in fixed child-port order
    for (uint8_t i = 0; i < CHILD_COUNT; i++) {
        uint8_t child_payload[MAX_CHILD_PAYLOAD_LEN];
        uint8_t child_payload_len = 0;
        bool child_received = false;

        // Retry same child[i] before moving to next child
        for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
            if (poll_child(
                    children[i],
                    child_payload,
                    MAX_CHILD_PAYLOAD_LEN,
                    &child_payload_len
                )) {
                child_received = true;
                break;
            }
        }

        // if child didn´t respond, end with loop and poll next child
        if (!child_received) {
            continue;
        }


        // if child responed, check if child payload fits into final payload
        if ((uint16_t)payload_len + child_payload_len > MAX_PAYLOAD_LEN) {
            continue;
        }

        // Child is valid and fits. Set child bit
        child_mask |= (1 << i);

        // Append child [i]s payload directly in child-port order to payload array
        for (uint8_t j = 0; j < child_payload_len; j++) {
            payload[payload_len++] = child_payload[j];
        }
    }

    /*
    * Write final child_mask into placeholder.
    */
    payload[2] = child_mask;

    /*
     * 5. Send complete frame upstream.
     */
    _delay_us(TURNAROUND_US);
    tx_frame(active_upstream, payload, payload_len);
    wire_release(active_upstream);

    /*
     * 6. Release all lines.
     */
    release_all_lines();

    /*
     * 7. Debug output.
     */
    Serial.print("Sent payload_len = ");
    Serial.println(payload_len);

    Serial.print("orientation = ");
    Serial.println(orientation_mask);

    Serial.print("child_mask = 0b");
    if ((child_mask & 0b10) == 0) {
        Serial.print("0");
    }
    Serial.println(child_mask, BIN);
}