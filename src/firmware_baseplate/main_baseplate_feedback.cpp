// ============================================================
// Prototype 5 - baseplate Node
// ATtiny1616
//
// Function:
// initiates and receives complete cube topology
// sends serialized topology via serial to PC for visualization
// ============================================================

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"
#include "feedback.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;
// ----------------------------------------------------------
// Wire descriptors
// ----------------------------------------------------------

static const wire_t child_0 = { &PORTB, PIN1_bm, 0 };  // PB1 — child port 1 (only child port of baseplate)

static const wire_t *children[CHILD_COUNT] ={
    &child_0,
};

//----------------------------------------------------------
// release all lines
//---------------------------------------------------------
static void release_all_lines(void){
    for (uint8_t line = 0; line < CHILD_COUNT; line ++){
        wire_release(children[line]);
    }
}

//-----------------------------------------------------------
// payload print
//-----------------------------------------------------------
static void print_payload_hex(const uint8_t *payload, uint8_t len)
{
    Serial.print("ordered_payload_len = ");
    Serial.println(len);

    Serial.print("ordered_payload = ");

    for (uint8_t i = 0; i < len; i++) {
        if (payload[i] < 0x10) {
            Serial.print("0");
        }

        Serial.println(payload[i], HEX);

        if (i < len - 1) {
            Serial.print(" ");
        }
    }

    Serial.println();
}

//feedback to child
//feedback led
//send feedback payload to child
static bool send_feedback_to_child(
    const wire_t *w,
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
)
{
    uint8_t b = 0;

    //brauch ich das? nicht in poll_child function
    wire_release(w);
    _delay_us(TURNAROUND_US);

    // 1. Send feedback command == CMD_STATUS to child (detection sequence)
    tx_byte(w, CMD_FEEDBACK);

    // 2. Release line and wait for child ACK
    _delay_us(TURNAROUND_US);
    wire_release(w);

    // wait for ACK_BUSY == same as in detection sequence
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        SER_PRINTLN("NFA");
        return false;
    }

    if (b != ACK_BUSY) {
        SER_PRINTLN("WFA");
        return false;
    }

    // 3. Send feedback frame == nothing that could be compared to the identification sequence
    /*
    tx_frame(children_pin, feedback_frame, feedback_len)
    */
    _delay_us(TURNAROUND_US);
    tx_frame(w, fb_payload, fb_payload_len);

    wire_release(w);

    _delay_us(TURNAROUND_US);
    
    // receive ack_finished valid/invalid if feedback frame received and processed from all conntected downstream cubes == same as data frame from child (detection sequence)
    if (!rx_byte(w, &b, FEEDBACK_FINISHED_TIMEOUT_US)){
        SER_PRINTLN("NFF");
        return false;
        }

    if (b == ACK_FINISHED) {
        SER_PRINTLN("CFF");

    }
    else if (b == ACK_FAILED) {
        SER_PRINTLN("FFF");  // feedback failed
    } 
    else{
        SER_PRINTLN("WFF");
        return false;
    }


    wire_release(w);
    return true;
}

// ----------------------------------------------------------
// Arduino setup
// ----------------------------------------------------------
void setup()
{
    wire_release(&child_0);
    PORTB.DIRSET = LED_PIN;     //define as output pin for led
    PORTB.OUTCLR = LED_PIN; 

    Serial.begin(115200);
    SER_PRINT("Prototype v5 parent started");
}

// ----------------------------------------------------------
// Main loop
// ----------------------------------------------------------
void loop()
{
    log_reset();
    // 0. make sure line is idle / give child time to get back to listening
    wire_release(&child_0);
    _delay_us(TURNAROUND_US);

    // 1. send CMD_STATUS to child
    //tx_byte(&child_0, CMD_STATUS);
    // wire_release(&child_0); 

    uint8_t child_payload[CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
    uint8_t child_payload_len[CHILD_COUNT] = {0};                // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[CHILD_COUNT] = {false};
    bool all_done = false; //flag to check if all children have responded

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt ++){
        for (uint8_t child = 0; child < CHILD_COUNT; child ++){
            //Serial.print("attempt ");
            //Serial.print(attempt);

            if (child_done[child]) {
                continue;
            }

            if (poll_child(
                children[child], 
                child_payload[child],
                MAX_CHILD_PAYLOAD_LEN,
                &child_payload_len[child]
            )){
                SER_PRINT("CV");
                child_done[child] = true; //mark child as done -> no more polling of this child in next attempts
                all_done = true;    // works correctly only for CHILD_COUNT = 1          
            }
        }
        if (all_done) {
            break;
        }
    }

    /*
     * 4. Build own/nodes payload:
     * Payload format: NODE_ID ORIENTATION CHILD_MASK CHILD_PAYLOADS...
     */
    uint8_t payload[MAX_PAYLOAD_LEN]; //final payload to be sent upstream
    uint8_t payload_len = 0;          //length of final payload
    

    //in a loop add children payloads to the final payload 
    for (uint8_t child = 0; child < CHILD_COUNT; child++) {
        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not set the child bit because the payload is not included.

        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
            continue;
        }

        //copy child payload into final payload
        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
            payload[payload_len++] = child_payload[child][j];  //copies stored payload into final payload and increases payload_len for next byte
        }
    }

    //PORTB.OUTTGL = LED_PIN;               // PB4 as LED output
    release_all_lines();

    _delay_us(3 * BYTE_US);

    bool feedback_done[CHILD_COUNT] = { false };
    bool feedback_all_done = false;

    // FEEDBACK FRAME to children - same as child polling (detection sequence)
        for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
            for (uint8_t child = 0; child < CHILD_COUNT; child++) {

                if (!child_done[child]) {
                    continue;   // no detected child
                }

                if (feedback_done[child]) {
                    continue;   // feedback already sent successfully
                }

                if (send_feedback_to_child(children[child], predefined_feedback_payload, FB_PAYLOAD_LEN))
                 {
                    SER_PRINTLN("CFA");
                    feedback_done[child] = true;
                    feedback_all_done = true;
                }
            }
            if (feedback_all_done){
                break;
            }
        } 

    #if SERIAL_DEBUG_END
        log_flush();
    #endif

    //Heartbeat sending
    bool changed = payload_changed (payload, payload_len);
    cycles_since_last_send ++;
    
    if (changed || cycles_since_last_send>= HEARTBEAT_INTERVAL_CYCLE) {

        #if SERIAL_WRITING 
        uint8_t checksum = calc_checksum(payload_len, payload);

        Serial.write(SYNC_BYTE);
        Serial.write(payload_len);
        Serial.write(payload, payload_len);
        Serial.write(checksum);

        #endif

        #if not SERIAL_WRITING
        print_payload_hex(payload, payload_len);
        #endif

        remember_sent_payload(payload, payload_len);
        cycles_since_last_send = 0;
    }
    

    #if SERIAL_DEBUG_END
        delay(50);
    #endif

}

//payload if tree didn´t work 
