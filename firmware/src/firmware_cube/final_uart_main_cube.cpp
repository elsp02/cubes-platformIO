// auch serial debug möglich 

// benötigte header files: 
// config.h -> für die ganzen constanten konfigurationen
// cube_hardware.h -> für upstream ports, child ports je nach type und child_count (noch richtig machen)
// cube_identity.h -> für brick types (in environment uart_cube bestimmt)
// feedback_cube.h -> für prüfen ob eigene ID in feedback payload integriert ist
// feedback.h -> für feedback weiter an bricks senden
// detection.h -> für child polling
// serial_writing.h -> für debug end (entscheiden ob ich das benutze)
// wire_bus.h -> für bus definitionen

//-----------------------------------------------
// Erklärung
//-----------------------------------------------

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "cube_hardware.h"
#include "cube_identity.h"
#include "feedback_cube.h"
#include "detection.h"
#include "serial_writing.h"
#include "wire_bus.h"


static bool last_child_present[MAX_CHILD_COUNT] = {false}; //error: expression must have a constant value


// ----------------------------------------------------------
// Fast upstream scan - vlt woanders hin verschieben
// scans all upstream lines for LOW and returns index of first detected LOW line (orientation value), or -1 if no line is LOW
// ----------------------------------------------------------
static int8_t scan_upstream(void)
{
    for (uint8_t i = 0; i < upstream_count; i++) {
        if (!is_line_high(&upstream[i])) { //error: expression must have a constant value
            return (int8_t)i;
        }
    }
    return -1;
}

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
        SER_PRINTLN("WC");
    }
}

// ----------------------------------------------------------
// Handle Detection
// ----------------------------------------------------------
static void handle_detection(const wire_t *active_upstream, uint8_t orientation_mask){
    /*
     * 2. Send ACK_BUSY upstream on the detected active line.
     */
    _delay_us(TURNAROUND_US);
    tx_byte(active_upstream, ACK_BUSY);
    wire_release(active_upstream);


     /*
     * 3. Poll own children with retries.
     */
    uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   //temporary storage (2d array) for child payload results -> child_payloads[child_index][payload_index] = byte received from child
     // problem of child_payload: always MAX_CHILD_PAYLOAD_LEN long even if e.g actual payload is just 3 bytes long -> not RAM efficient
    uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                 // temporary storage for child payload lengths -> child_payload_len[child_index] = length of payload received from child
    bool child_done[MAX_CHILD_COUNT] = {false};                       // stores if child has already responded and can be skipped
    bool child_acked[MAX_CHILD_COUNT] = {false};                      // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
        bool retry_needed = false; //true if any child still has attempts left after this round

        for (uint8_t i = 0; i < child_count; i++) {  //child loop, iterates through children

            if (child_done[i]) {
                continue;
            }

            // presence-aware retry budget: a port counts as occupied if it had a child last cycle OR already ACKed this cycle
            // Occupied ports keep the full retries, empty ports get a single attempt.
            // -> attempt_budget specifies the maximum number of attempts a the port is allowed in this detection cycle
            uint8_t attempt_budget = (last_child_present[i] || child_acked[i]) ? CHILD_RETRIES : 1;

            if (attempt >= attempt_budget) {
                continue;
            }

            bool acked = false;

            if (poll_child(
                    children[i],           //with wire/pin of child[i]
                    child_payload[i],     //and receive and store the payload in child_payloads[i]
                    MAX_CHILD_PAYLOAD_LEN, //with max length of MAX_CHILD_PAYLOAD_LEN to avoid overflow
                    &child_payload_len[i], //and stores the received payload length from child[i]
                    &acked
            )){
                SER_PRINTLN("CV");
                child_done[i] = true; //mark child as done -> no more polling of this child in next attempts

            #if defined(CUBE_TYPE_NORMAL)
                            // Special case: orientation offset for port 1 (Out2, -Y).
                            // Only the normal brick's port 1 has this mounting rotation
                            if (i == 1) {
                                child_payload[i][1] =
                                    (child_payload[i][1] + 3u) % 4u;
                            }
            #endif
            } else {
                if (acked) {
                    child_acked[i] = true; // present but frame failed -> full retry budget from now on
                    retry_needed = true;
                } else if (attempt + 1 < attempt_budget) { //if child was present in the previous detection loop - then also retry
                    retry_needed = true;
                }
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    // for feedback loop to know at which port to send the feedback frame
    for (uint8_t child = 0; child < child_count; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
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
    for (uint8_t child = 0; child < child_count; child ++) {
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
    SER_PRINT("CM");

    if ((child_mask & 0b10) == 0) {
        SER_PRINT("0");
    }
    SER_PRINTLN2(child_mask, BIN);

    /*
     send data frame to parent
     */
    _delay_us(TURNAROUND_US);
    tx_frame(active_upstream, payload, payload_len);
}

//----------------------------------------------------------
// Handle Feedback - vlt auch in feedback_cube.cpp file hin verschieben 
//----------------------------------------------------------
// handle feedback -> if CMD_FEEDBACK do feedback led sequence
static void handle_feedback (const wire_t *active_upstream){

        uint8_t fb_payload[MAX_PAYLOAD_LEN];
        uint8_t fb_payload_len = 0;

        // 1. ACK to parent == ack to parent (detection sequence)
        _delay_us(TURNAROUND_US);
        tx_byte(active_upstream, ACK_BUSY);

        //why needed
        //_delay_us(TURNAROUND_US);
        wire_release(active_upstream);

        //receive feedback payload == nothing that could be compared to the identification sequence

        if (!rx_frame(
                active_upstream,
                fb_payload,
                MAX_PAYLOAD_LEN,
                &fb_payload_len,
                CHILD_TIMEOUT_US,
                INTER_FRAME_TIMEOUT_US
            )) {
            _delay_us(TURNAROUND_US);
            tx_byte(active_upstream, ACK_FAILED); // if rx_frame failed, send ack_failed to parent
            wire_release(active_upstream);
            return;
        }

        // 3. Apply the frame to the own LED:
        // true  = own ID was in the payload (LED set green/red inside),
        // false = own ID absent -> LED switched off
        if (feedback_contains_own_id(fb_payload, fb_payload_len)) {
            SER_PRINTLN("FI");  // feedback: own id included
        } else {
            SER_PRINTLN("FO");  // feedback: own id absent, LED off
        }

        //relay identical cmd_feedback to children == polling children
        bool all_feedback_done = true;

        //frame to existing children == polling children (detection sequence)
            for (uint8_t child = 0; child < child_count; child++) {  //child loop, iterates through children

                if (!last_child_present[child]) {
                    continue;
                }

                //if one send feedback to child return a false - then end loop and transmit ACK failed to parent
                if (!send_feedback_to_child(children[child], fb_payload, fb_payload_len)){
                    all_feedback_done = false;
                    _delay_us(TURNAROUND_US);
                    tx_byte(active_upstream, ACK_FAILED);
                    return;   // stop handle_feedback() immediately

                }
            }

            // if all send feedback to child were valid, send ACK_FINISHED (Only reached if every existing child succeeded)
            _delay_us(TURNAROUND_US);
            tx_byte(active_upstream, ACK_FINISHED);

        _delay_us(TURNAROUND_US);

        wire_release(active_upstream);
    }
//--------------------------------------------------------------------------

// ----------------------------------------------------------
// Arduino setup - release all lines
// ----------------------------------------------------------

void setup()
{
    release_all_lines();
    // Configure LED pins as outputs.
    PORTB.DIRSET = GREEN_LED_PIN | RED_LED_PIN;

    // LEDs initially off.
    PORTB.OUTCLR = GREEN_LED_PIN | RED_LED_PIN;

    Serial.begin(115200);
    Serial.println("final_uart_main_cube started");
}

// ----------------------------------------------------------
// Main loop
// ----------------------------------------------------------

void loop()
{
    //log_reset();
    /*
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
        handle_detection(active_upstream, orientation_mask);
    }  else {

        /*
        * Safety check.
        * Should normally never be true after orientation_known == true.
        */
        if (active_upstream == nullptr) {
            orientation_known = false;
            release_all_lines();
            return;
        }

        // if orientation is already known, no need to check orientation just receive CMD_STATUS
        uint8_t b = 0;
        if (!rx_byte(active_upstream, &b, PARENT_TIMEOUT_US)) {
            //Serial.println("NC");
            return;
        }

        //check if received byte is CMD_STATUS or CMD_FEEDBACK
        switch (b) {
            case CMD_STATUS:
                handle_detection(active_upstream, orientation_mask);
                break;

            case CMD_FEEDBACK:
                handle_feedback(active_upstream);
                break;

            default:
                SER_PRINTLN("WC");
                return;
        }
    }

    wire_release(active_upstream);

    release_all_lines();

    #if SERIAL_DEBUG_END
        log_flush();
    #endif

}

