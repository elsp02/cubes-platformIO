#include "config.h"
#include "feedback.h"
#include "wire_bus.h"
#include "serial_writing.h"

#include <util/delay.h>

bool feedback_contains_own_id(const uint8_t *payload, uint8_t len)
{   bool found_own_id = false;
    // i + 1 < len: each entry is an (ID, LED_STATE) pair, so never read
    // a state byte past the end of an odd-length payload
    for (uint8_t i = 0; i + 1 < len; i+=2) {
        if (payload[i] == NODE_ID) {
            found_own_id = true;
            uint8_t led_state = payload[i+1];

            if (led_state == LED_GREEN) {
                  PORTB.OUTSET = GREEN_LED_PIN;  //set green pin high
                  PORTB.OUTCLR = RED_LED_PIN;       //set red pin low (or turn rgb led to red)}
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
    // if own ID not inlcuded, turn led off
      if (!found_own_id){    
          PORTB.OUTCLR = GREEN_LED_PIN | RED_LED_PIN;
          SER_PRINTLN("n");
        
        }
    return false;
}



//predefined feedback payloads
const  uint8_t predefined_feedback_payload[4][FB_MAX_PAYLOAD_LEN] = {
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
const  uint8_t predefined_feedback_payload_len[] = {
    2,
    4,
    6,
    2,
};

