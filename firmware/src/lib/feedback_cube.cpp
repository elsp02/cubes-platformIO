#include "feedback_cube.h"

#include "config.h"
#include "cube_identity.h"
#include "serial_writing.h"


#include <avr/io.h>

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