// ============================================================
// Prototype v5 - child Node
// ATtiny1616
//
// function:
// receives cube topology? request from parent
// polls all its children for their subtree cube data
// sends aggregated cube tree data to its parent
// ============================================================

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"

// ----------------------------------------------------------
// Wire descriptors- same as v4
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

//---------------------------------------------------------
// release all lines
//---------------------------------------------------------
static void release_all_lines(void){
    for (uint8_t line= 0; line < upstream_count; line ++){
        wire_release(&upstream[line]);
    }

    for (uint8_t line = 0; line < CHILD_COUNT; line ++){
        wire_release(children[line]);
    }
}


// ----------------------------------------------------------
// Fast upstream scan - same as v4
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

//-----------------------------------------------------------
// wait for CMD byte from parent
//-----------------------------------------------------------
// auch auf falling edge warten (rx_byte) aber ohne timeout

// ----------------------------------------------------------
// Wait for upstream command - same as v4 despite from release all lines
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

        if (!rx_byte_frame(w, &b)) { //receiving of message (sent bits) without start bit, false if no valid bits are received within timeout
            continue;
        }

        //checks if received byte is CMD_STATUS, if not, repeat orientation scan and go into loop
        if (b != CMD_STATUS) {  
            release_all_lines();
            continue;
        }
        
        // if correct CMD_STATUS is received, ausgabeparameter aus funktion: assign detected line to active_line and orientation value to orientation and return true
        *active_line = w;
        *orientation_mask = (uint8_t)ori;

        return true;
    }
}

// Scans the upstream line for CMD_STATUS, discarding any stray bytes until  CMD_STATUS arrives or the line stays idle for
// Returns true if CMD_STATUS found, false on idle timeout.
static bool wait_for_cmd_status(const wire_t *w)
{
    while (true) {
        uint8_t b = 0;

        // Wait up to PARENT_TIMEOUT_US for any byte to arrive at all.
        if (!rx_byte(w, &b, PARENT_TIMEOUT_US)) {
            return false;   // genuine idle -- nothing sent at all
        }

        // A byte arrived. Is it what we wanted?
        if (b == CMD_STATUS) {
            return true;    // found it, done
        }

        // Wrong byte -- discard and keep scanning,
        // same as find_sync_byte discarding non-SYNC bytes.
        Serial.println("WC");
    }
}
//-----------------------------------------------------------
// Converts a uint8_t (0-255) to a decimal string. buf must be at least 4 bytes.
static void format_u8(uint8_t value, char *buf)
{
    if (value >= 100) {
        buf[0] = '0' + (value / 100);
        value %= 100;
        buf[1] = '0' + (value / 10);
        buf[2] = '0' + (value % 10);
        buf[3] = '\0';
    } else if (value >= 10) {
        buf[0] = '0' + (value / 10);
        buf[1] = '0' + (value % 10);
        buf[2] = '\0';
    } else {
        buf[0] = '0' + value;
        buf[1] = '\0';
    }
}

// ----------------------------------------------------------
// Poll one child port- rx frame  is missing
// ----------------------------------------------------------

static bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len)
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
        Serial.println("NA");
        return false;
    }

    if (b != ACK_BUSY) {
        Serial.println("WA");
        return false;
    }

    Serial.println("CA");
    /*
     * 4. ACK received, now wait for child data byte.
     */

    if (!rx_frame(
            w,
            data_out,
            max_child_payload_len,
            child_payload_len,
            FRAME_TIMEOUT_US,
            INTER_FRAME_TIMEOUT_US
        )) {
        Serial.println("WD");
        return false;
    }

    return true;
}

// ----------------------------------------------------------
// Arduino setup - release all lines
// ----------------------------------------------------------

void setup()
{
    release_all_lines();

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
     * same as v4
     */
    static bool orientation_known = false;
    static const wire_t *active_upstream = nullptr; //code merkt sich dauerhaft die Orientierungsleitung
    static uint8_t orientation_mask = 0x00; //orientation mask,now 1 byte, later combined with child_mask to one byte 

    /*
     * 1. Detect orientation only once.
     */
    if (!orientation_known) {
        wait_for_valid_upstream_cmd(&active_upstream, &orientation_mask); // selects active upstream line and orientation value (orientation value must be transformed to orientation_byte for sending )
        orientation_known = true;
    }  else {

        // instead of function underneath it 
        //if (!wait_for_cmd_status(active_upstream)) {
        //    log_line("NC");
        //    return;
        // }
        //}
        
        // if orientation is already known, no need to check orientation just receive CMD_STATUS
        uint8_t b = 0;
        if (!rx_byte(active_upstream, &b, PARENT_TIMEOUT_US)) {
            //Serial.println("NC");
            return;
        }

        if (b != CMD_STATUS) {
            Serial.println("WC");
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
    /*wire_release(active_upstream);


     /*
     * 3. Poll own children with retries.
     *
     * Child payloads are stored separately first.
     * This keeps the final payload order correct:
     * child 0 payload first, then child 1 payload.
     */
    uint8_t child_payload[CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
     // problem of child_payload: always MAX_CHILD_PAYLOAD_LEN long even if e.g actual payload is just 3 bytes long -> not RAM efficient 
    uint8_t child_payload_len[CHILD_COUNT] = {0};                 // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[CHILD_COUNT] = {false};                       // stores if child has already responded and can be skipped

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
        for (uint8_t i = 0; i < CHILD_COUNT; i++) {  //child loop, iterates through children

            if (child_done[i]) {
                continue;
            }

            if (poll_child(
                    children[i],           //with wire/pin of child[i]
                    child_payload[i],     //and receive and store the payload in child_payloads[i]
                    MAX_CHILD_PAYLOAD_LEN, //with max length of MAX_CHILD_PAYLOAD_LEN to avoid overflow
                    &child_payload_len[i]  //and stores the received payload length from child[i])) {
            )){
                Serial.println("CV");
                //char num_buf[4];
                //char line[32];
                //format_u8(i, num_buf);
                //strcpy(line, "CV");
                //strcat(line, num_buf);   // i hasn't changed, num_buf is still valid
                //log_line(line);
                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts
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

    //add own payload to payload array
    payload[payload_len++] = NODE_ID;
    payload[payload_len++] = orientation_mask; 
    payload[payload_len++] = 0x00;  //placeholder for child_mask

    //in a loop add children payloads to the final payload 
    for (uint8_t child = 0; child < CHILD_COUNT; child ++) {
        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not set the child bit because the payload is not included.

        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
            continue;
        }

        //create child_mask
        child_mask |= (1 << child);   //set bit for child[i]n in child_mask (LSB = child 0)

        //copy child payload into final payload
        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
            payload[payload_len++] = child_payload[child][j];  //copies stored payload into final payload and increases payload_len for next byte
        }
    }

    payload[2] = child_mask;

    /*
     * 4. Print/debug childmask
     */
    Serial.print("CM");

    if ((child_mask & 0b10) == 0) {
        Serial.print("0");
    }
    Serial.println(child_mask, BIN);

    /*
     * 5. Send predefined DATA_BYTE upstream.
     */
    _delay_us(TURNAROUND_US);
    
    //log_lineln("data byte gesendet, loop von neu");
    tx_frame(active_upstream, payload, payload_len);
    wire_release(active_upstream);
    
    release_all_lines();
    //log_flush();
   
}