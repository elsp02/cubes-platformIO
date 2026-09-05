// =====================================================================
// feedback_cube.cpp
// - feedback handling for bricks: local LED control and relaying
//   feedback frames one hop further down the tree
// =====================================================================

#include "feedback_cube.h"

#include "config.h"
#include "wire_bus.h"
#include "cube_identity.h"
#include "serial_writing.h"

#include <tinyNeoPixel_Static.h>

#include <avr/io.h>
#include <util/delay.h>

namespace {
    constexpr uint8_t RGB_LED_DATA_PIN = PIN_PB5;
    constexpr uint8_t RGB_LED_COUNT = 1;
    uint8_t rgb_pixel_buffer[RGB_LED_COUNT * 3] = {0};
    tinyNeoPixel rgb_led(RGB_LED_COUNT, RGB_LED_DATA_PIN, NEO_GRB + NEO_KHZ800, rgb_pixel_buffer);

    void rgb_led_init()
    {
        static bool initialized = false;
        if (initialized) return;
        pinMode(RGB_LED_DATA_PIN, OUTPUT);
        digitalWrite(RGB_LED_DATA_PIN, LOW);
        delay(10); // LED benötigt mindestens 200 µs LOW als Reset
        initialized = true;
    }
}


// feedback_contains_own_id
// - scans payload for this brick's NODE_ID and sets the local LED accordingly
// - true only once this brick's own ID was found in the payload
bool feedback_contains_own_id(const uint8_t *payload, uint8_t len)
{   bool found_own_id = false;
    // i + 1 < len: each entry is an (ID, LED_STATE) pair, so never read
    // a state byte past the end of an odd-length payload
    for (uint8_t i = 0; i + 1 < len; i+=2) {
        if (payload[i] == NODE_ID) {
            found_own_id = true;
            uint8_t led_state = payload[i+1];

            // currently incorrect because a adressable rgb led is used
            if (led_state == LED_GREEN) {
                  PORTB.OUTSET = GREEN_LED_PIN;  
                  PORTB.OUTCLR = RED_LED_PIN;   
                  SER_PRINTLN("g");
                  return true;
              } else if (led_state == LED_RED){
                  PORTB.OUTCLR = GREEN_LED_PIN;
                  PORTB.OUTSET   = RED_LED_PIN;
                  SER_PRINTLN("r");
              } 
              return true; 
          }
    }
    // if own ID not inlcuded in FEEDBACK PAYLOAD, turn LED off
      if (!found_own_id){    
          PORTB.OUTCLR = GREEN_LED_PIN | RED_LED_PIN;
          SER_PRINTLN("n");
        
        }
    return false;
}

bool feedback_contains_own_id_rgb(const uint8_t *payload, uint8_t len)
{   rgb_led_init();
    bool found_own_id = false;
    // i + 1 < len: each entry is an (ID, LED_STATE) pair, so never read
    // a state byte past the end of an odd-length payload
    for (uint8_t i = 0; i + 1 < len; i+=2) {
        if (payload[i] == NODE_ID) {
            found_own_id = true;
            uint8_t led_state = payload[i+1];

            if (led_state == LED_GREEN) {
                  rgb_led.setPixelColor(0, 0, 40, 0);
                  rgb_led.show();
                  SER_PRINTLN("g");
              } else if (led_state == LED_RED){
                  rgb_led.setPixelColor(0, 40, 0, 0);
                  rgb_led.show();
                  SER_PRINTLN("r");
              }
              return true;
          }
    }
    // if own ID not inlcuded in FEEDBACK PAYLOAD, turn LED off
      if (!found_own_id){
          rgb_led.setPixelColor(0, 0, 0, 0);
          rgb_led.show();
          SER_PRINTLN("n");

        }
    return false;
}



// send_feedback_to_child
// - relays a feedback frame to one child port and waits for it to finish
// - true only on ACK_FINISHED from the child (after its own recursive relay)
// -> mirrors the CMD_STATUS/ACK/DATA_FRAME shape of poll_child, but for feedback
bool send_feedback_to_child(
    const wire_t *w,
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
){
    uint8_t b = 0;

    wire_release(w);
    _delay_us(TURNAROUND_US);

    // 1. Send feedback command == same as in detection sequence (but with CMD_STATUS)
    tx_byte(w, CMD_FEEDBACK);

    wire_release(w);

    // 3. wait for ACK_BUSY == same as in detection sequence
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        SER_PRINTLN("NFA");
        return false;
    }

    if (b != ACK_BUSY) {
        SER_PRINTLN("WFA");
        return false;
    }

    // 3. Send feedback frame
    _delay_us(TURNAROUND_US);
    tx_frame(w, fb_payload, fb_payload_len);
    wire_release(w);



    // 3. Wait for child's recursive feedback relay to finish == comparable with DATA_FRAME from child in detection sequence
    if (!rx_byte(w, &b, FEEDBACK_FINISHED_TIMEOUT_US)) {
        SER_PRINTLN("NFF");   // no feedback finished
        return false;
    }

    wire_release(w);
    switch (b) {
        case ACK_FINISHED:
            SER_PRINTLN("CFF");
            return true;

        case ACK_FAILED:
            SER_PRINTLN("FFF");
            return false;

        default:
            SER_PRINTLN("WFF");
            return false;
    }
}