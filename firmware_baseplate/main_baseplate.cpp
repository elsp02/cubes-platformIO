// ============================================================
// Prototype v3_2 - baseplate Node
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
#include "tree_parser.h"

// ----------------------------------------------------------
// Wire descriptors
// ----------------------------------------------------------

static const wire_t child_0 = { &PORTB, PIN0_bm, 0 };  // PB0 — child port 0 (only child port of baseplate)

static const wire_t *children[CHILD_COUNT] ={
    &child_0,
};

static void release_all_lines(void)
{
    for (uint8_t i = 0; i < CHILD_COUNT; i++){
        wire_release(children[i]);
    }
}


//----------------------------------------------------------
// Poll one child port
//----------------------------------------------------------

static bool poll_child(
    const wire_t *w,
    uint8_t *child_payload,
    uint8_t max_child_payload_len,
    uint8_t *child_payload_len
)
{
    uint8_t b= 0;

    /*
    * 1. Send CMD_STATUS to child, *w = wire for child[i]
    */
   tx_byte(w,CMD_STATUS);

   /*
   *2. Switch direction / wait before waiting
   */
    _delay_us(TURNAROUND_US);

    /*
    * 3. wait for ACK_BUSY
    */
   if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
    return false;
   }

   if (b != ACK_BUSY) {   //maybe could be merged together -> proof of correctness already in rx_byte
    return false;
   }

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
    PORTB.DIRSET = LED_PIN;     //define as output pin for led
    PORTB.OUTCLR = LED_PIN; 

    Serial.begin(9600);
    Serial.println("Prototype v3 baseplate started");
}

// ----------------------------------------------------------
// Main loop
// ----------------------------------------------------------
void loop()
{
    /*
    *1. Poll own children with retries -> one after another (currently just 1 child port in baseplate)
    */
   uint8_t ordered_payload[MAX_CHILD_PAYLOAD_LEN];          //also payload array with fixed length??
   uint8_t ordered_payload_len = 0;
   uint8_t child_mask = 0x00;  //placeholder for child_mask

       // Own node data first
    ordered_payload[ordered_payload_len++] = NODE_ID;
    ordered_payload[ordered_payload_len++] = 0x00;   //baseplate has no orientation
    ordered_payload[ordered_payload_len++] = child_mask; 

   // Poll children and its payload one after another in a fixed child-port order (currently just 1 child)
   for (uint8_t i=0; i < CHILD_COUNT; i++) {
        uint8_t child_payload[MAX_CHILD_PAYLOAD_LEN];
        uint8_t child_payload_len = 0;
        bool child_received = false;

        //retry same child[i] before moving to next child
        for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt ++){
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
        // if child didn´t respond -> no child at port -> end with loop and poll next child
        if (!child_received){
            continue;
        }

                // if child responed, check if child payload fits into final payload
        if ((uint16_t)ordered_payload_len + child_payload_len > MAX_PAYLOAD_LEN) {
            continue;
        }

        // Child is valid and fits. Set child bit
        child_mask |= (1 << i);

        //append child[i]s payload (bytewise) directly in child-port order to ordered_payload array
        for (int8_t j = 0; j< child_payload_len; j++){
            ordered_payload[ordered_payload_len++] = child_payload[j]; //???? warum kein append? wird das nicht hinzugefügt?
        }
   }

    /*
    * Write final child_mask into placeholder.
    */
    ordered_payload[2] = child_mask;

    /*
     * 5. Send complete frame upstream.
     */
    _delay_us(TURNAROUND_US);
    release_all_lines();

    // parser = descent recursive parser (=deserialization) for the preorder serialized n-ary tree payload
    // ------------------------------------------------------------
    uint8_t payload_read_index = 0;

    int8_t root_node_storage_index = parse_node(ordered_payload, ordered_payload_len, &payload_read_index);  //&...index because its defined as a real variable -> need to pass its adress to the function

    // failed safety checks 
    if (root_node_storage_index < 0){
        Serial.println("parser error");
        return;
    }

    //check if the final payload_read_index is the same as payload_len to see if parser consumed all bytes from ordered_payload
    if (payload_read_index != ordered_payload_len){
        Serial.println("unused payload bytes left");
        return;
    }

    Serial.println("tree parsed sucessfully");

    //prints deserialized tree
    print_tree(root_node_storage_index,0);   
    
}