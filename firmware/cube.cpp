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
static const uint8_t upstream_count = sizeof(upstream) / sizeof(upstream[0]);

static const wire_t child_0 = { &PORTB, PIN0_bm, 0 };  // PB0 — child port 0
static const wire_t child_1 = { &PORTB, PIN1_bm, 1 };  // PB1 — child port 1

static const wire_t *children[CHILD_COUNT] = {
    &child_0,
    &child_1
};

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
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) { //!!CHILD_TIMEOUT_US must be calculated
        return false;
    }

    /// SYNC  byte check
    /// receive sync byte and check for validity, if not valid, break 

    /// LEN  byte
    /// receive LEN Data byte from child -> LEN_gesamt += LEN_byte and LEN_loop_child = LEN_byte

    /// Payload Bytes 
    /// for LEN_loop_child times: receive payload byte from child and childrens children (ID BYTE, Orientation BYTE, Child_mask BYTE -> always 8 data bits and 1 stop bit)

    /// Store received payload data in child_data array? - or maybe stored differently

    /// CRC byte
    /// receive CRC byte at the end and check for validity, if not valid, trash everything received from this child and break
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
    for (uint8_t i = 0; i < upstream_count; i++) {
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
    static uint8_t orientation_mask = 0x00; //orientation mask,now 1 byte, later combined with child_mask to one byte 
    /// create variables (LEN_gesamt, LEN_Loop child etc.)

    /*
     * 1. Detect orientation only once.
     */
    if (!orientation_known) {
        wait_for_valid_upstream_cmd(&active_upstream, &orientation_mask); // selects active upstream line and orientation value (orientation value must be transformed to orientation_byte for sending )
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
    //wire_release(active_upstream);

    /*
     * 3. Poll own children with retries.
     */
    uint8_t child_mask = 0x00; // 1byte to mask connected children
    uint8_t child_data[CHILD_COUNT] = {0};  //Child_count = amount of children (in this case 2), ?child_data array stores received data from children, index in array corresponds to child index in children array
    bool child_done[CHILD_COUNT] = {false}; //child_done array stores if child has already responded with valid data

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
        for (uint8_t i = 0; i < CHILD_COUNT; i++) {  //child loop, iterates through children

            if (child_done[i]) { //if child[i] has already responded with valid data, skip polling and go to next child
                continue;
            }

            if (poll_child(children[i], &child_data[i])) { //poll child[i], if valid data is received, then ...
                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts
                child_mask |= (1 << i); //set bit i in child_mask to note that child[i] is there (and has responded with valid data)
            }
            /// maybe here LEN_gesamt += LEN_byte calculatioon?
        }
    }

    /// if every child is done, create the total array own data (own LEN, ID, orientation and child mask) and  all received data from children, which will be sent upstream after the loop
    /// then create total data frame which will be sent upstream, consisting of SYNC byte, LEN byte (total), Payload bytes (total), CRC byte

    /*
     * 4. Print/debug result.
     */
    Serial.print("Final child_mask = 0b");

    if ((child_mask & 0b10) == 0) {
        Serial.print("0");
    }

    Serial.println(child_mask, BIN);

    
    /// 5. Send the created Data frame upstream.
    /// for LEN byte gesamt times: send SYNC byte, LEN byte (total), Payload bytes (total), CRC byte
    
    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, DATA_BYTE);
    wire_release(active_upstream);

    // 5. release all lines
    for (uint8_t i = 0; i < upstream_count; i++) {
        wire_release(&upstream[i]);
    }
    wire_release(&child_0);
    wire_release(&child_1); 
}