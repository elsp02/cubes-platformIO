#include "config.h"
#include "feedback.h"
#include "wire_bus.h"

#include <util/delay.h>

#define FEEDBACK_COUNT (sizeof(feedback_payload_lens) / sizeof(feedback_payload_lens[0]))

uint8_t feedback_index = 0;

//--------------------
const uint8_t predefined_feedback_payload[FB_PAYLOAD_LEN] = {
    0x12, LED_GREEN
};

bool is_expected_feedback_payload(const uint8_t *payload, uint8_t len)
{
    if (len != FB_PAYLOAD_LEN) {
        return false;
    }

    for (uint8_t i = 0; i < FB_PAYLOAD_LEN; i++) {
        if (payload[i] != predefined_feedback_payload[i]) {
            return false;
        }
    }

    return true;
}



//predefined feedback payloads
/*const  uint8_t feedback_payloads[FEEDBACK_COUNT][FB_MAX_PAYLOAD_LEN] = {
    // Payload 0: only cube A green, B and C off
    { CUBE_A_ID, LED_GREEN },

    // Payload 1: A green, B red, C off
    { CUBE_A_ID, LED_GREEN,
      CUBE_B_ID, LED_RED },

    // Payload 2: all three green
    { CUBE_A_ID, LED_GREEN,
      CUBE_B_ID, LED_GREEN,
      CUBE_C_ID, LED_GREEN },

    // Payload 3: only cube C red, A and B off
    { CUBE_C_ID, LED_RED },
};


// predefined feedback payload length 
const  uint8_t feedback_payload_lens[] = {
    2,
    4,
    6,
    2,
};



//evaluate feedback payload
static void apply_feedback_payload(const uint8_t *fb_payload, uint8_t fb_payload_len){
  bool found_own_id = false;
      for (uint8_t i=0; i < fb_payload_len; i+=2){
          if (fb_payload[i] == NODE_ID){
              found_own_id = true;
              uint8_t led_state = fb_payload[i+1];

              if (led_state == LED_GREEN) {
                  PORTB.OUTSET = GREEN_LED_PIN;  //set green pin high
                  PORTB.OUTCLR = RED_LED_PIN;       //set red pin low (or turn rgb led to red)}
                  Serial.println("g");
              } else if (led_state == LED_RED){
                  PORTB.OUTCLR = GREEN_LED_PIN;
                  PORTB.OUTSET   = RED_LED_PIN;
                  Serial.println("r");
              } 
              break; 
          }
      // if own ID not inlcuded, turn led off
      if (!found_own_id){    
          PORTB.OUTCLR = GREEN_LED_PIN;
          PORTB.OUTCLR   = RED_LED_PIN;
          Serial.println("n");
        }
      }
  }
*/