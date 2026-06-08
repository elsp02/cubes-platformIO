// ============================================================
// Prototype v3_2 - child Node
// child polling: children in a loop 
// payload stored in 2D array -> always fixed length -> not RAM efficient 
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
        // Safety check. Should normally never be true after orientation_known == true.
        if (active_upstream == nullptr) {
            orientation_known = false;
            return;
        }
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
     * 2. Send ACK_BUSY upstream on the detected active line.
     */
    _delay_us(TURNAROUND_US); 
    tx_byte(active_upstream, ACK_BUSY);
    //wire_release(active_upstream);

     /*
     * 3. Poll own children with retries.
     *
     * Child payloads are stored separately first.
     * This keeps the final payload order correct:
     * child 0 payload first, then child 1 payload.
     */
    uint8_t child_payloads[CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
     // problem of child_payload: always MAX_CHILD_PAYLOAD_LEN long even if e.g actual payload is just 3 bytes long -> not RAM efficient 
    uint8_t child_payload_len[CHILD_COUNT] = {0};                 // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[CHILD_COUNT] = {false};                       // stores if child has already responded and can be skipped

    // poll children with retries
    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //loop for every retry
        for (uint8_t i = 0; i < CHILD_COUNT; i++) { //loop for every child

            if (child_done[i]) {   // if child[i] has already responded -> true -> skip
                continue;
            }

            //receives childs payload and payload length and stores it in temporary storages 
            if (poll_child(                //poll child[i] 
                    children[i],           //with wire/pin of child[i]
                    child_payloads[i],     //and receive and store the payload in child_payloads[i]
                    MAX_CHILD_PAYLOAD_LEN, //with max length of MAX_CHILD_PAYLOAD_LEN to avoid overflow
                    &child_payload_len[i]  //and stores the received payload length from child[i]
                )) {
                child_done[i] = true;      //if everything correct sets child_done[i] to true -> this child will be skipped in next attempts
            }
        }
    }

    /*
     * 4. Build own/nodes payload:
     * Payload format: NODE_ID ORIENTATION CHILD_MASK CHILD_PAYLOADS...
     */
    uint8_t payload[MAX_PAYLOAD_LEN]; //final payload to be sent upstream
    uint8_t payload_len = 0;          //length of final payload
    uint8_t child_mask = 0x00;        //child_mask to be sent in final payload

    //stores own payload into the first payload position, ++ = incresas payload_len after writing, so next byte will be written on the next position
    payload[payload_len++] = NODE_ID; //writes NODE_ID into the first free payload position
    payload[payload_len++] = orientation_mask; //writes orientation mask byte into the next free payload position
    payload[payload_len++] = 0x00;   // placeholder for child_mask
    // e.g payload[0] = NODE_ID, payload[2]= 0x00; payload_len = 3

    //in a loop add children payloads to the final payload 
    for (uint8_t i = 0; i < CHILD_COUNT; i++) {
        if (!child_done[i]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not set the child bit because the payload is not included.

        //if ((uint16_t)payload_len + child_payload_len[i] > MAX_PAYLOAD_LEN) {
            //continue;
        //}

        //create child_mask
        child_mask |= (1 << i);   //set bit for child[i]n in child_mask (LSB = child 0)

        //copy child payload into final payload
        for (uint8_t j = 0; j < child_payload_len[i]; j++) {
            payload[payload_len++] = child_payloads[i][j];  //copies stored payload into final payload and increases payload_len for next byte
        }
    }

    // Now write final child_mask into own node header.
    payload[2] = child_mask;  //before was the placeholder 0x00 in payload[2] 

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