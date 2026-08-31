// enthält allgemeinen Bus Treiber und keine konkrete Hardwarebelegung (damit die Funktionen von allen Modulen genutzt werden können)
// -> wie art schablone bzw lückentext und das spezielle wird dann in den Modulen definiert

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"

#include <util/delay.h>

// ----------------------------------------------------------
// Wire primitives
// examples:
// line_release(const wire_t *w)  = function definition
// line_release(&upstream)       = function call with &upstream pin defined in wire_t as argument
// ----------------------------------------------------------

void wire_release(const wire_t *w)
{
    // Logic high: release the line and enable internal pull-up.
    w->port->OUTCLR = w->pin_bm;         //clear latch
    w->port->DIRCLR = w->pin_bm;         // define as input (wire high)

    switch (w->pin_idx) { //enables internal pull ups depending on pin_idx
        case 0: w->port->PIN0CTRL = PORT_PULLUPEN_bm; break;
        case 1: w->port->PIN1CTRL = PORT_PULLUPEN_bm; break;
        case 2: w->port->PIN2CTRL = PORT_PULLUPEN_bm; break;
        case 3: w->port->PIN3CTRL = PORT_PULLUPEN_bm; break;
        case 4: w->port->PIN4CTRL = PORT_PULLUPEN_bm; break;
        case 5: w->port->PIN5CTRL = PORT_PULLUPEN_bm; break;
        case 6: w->port->PIN6CTRL = PORT_PULLUPEN_bm; break;
        case 7: w->port->PIN7CTRL = PORT_PULLUPEN_bm; break;
        default: break;
    }
}

void wire_low(const wire_t *w)
{
    // Logic low: actively pull line to GND.

    w->port->OUTCLR = w->pin_bm;      //clear latch
    w->port->DIRSET = w->pin_bm;      // define as output (wire low)
}

bool is_line_high(const wire_t *w)
    // checks if the line is high

{
    return (w->port->IN & w->pin_bm) != 0;       //read wheter selected line is high or low -> returns true (high) or false (low)
}

// ----------------------------------------------------------
// Byte transmit
// transmission of data frame (start bit, data bits, stop bit)
// ----------------------------------------------------------

void tx_byte(const wire_t *w, uint8_t b)
{
    /*
     * UART-like byte:
     * start bit = 0
     * 8 data bits, LSB first
     * stop bit = 1
     */

    // Start bit
    wire_low(w);
    _delay_us(BAUD_US);

    // Data bits
    for (uint8_t i = 0; i < 8; i++) {
        if (b & 1) {
            wire_release(w);     // logic 1
        } else {
            wire_low(w);         // logic 0
        }

        _delay_us(BAUD_US);
        b >>= 1;
    }

    // Stop bit
    wire_release(w);
    _delay_us(BAUD_US);
}

// ----------------------------------------------------------
// Normal byte receive
// Detection of start bit and then reception of data frame (data bits and stop bit)
//
// micros: better than the previous timeout measurement (before v7) because of an
// specific time rather than just an approximate number of passes through the loop.
// Timing constraint: entry latency shifts every bit sample point of the
// byte late, and inside a frame the next start bit may already be on the
// line. So: check the line BEFORE any micros() call, and while waiting
// poll the line several times per (comparatively slow) micros() read.
// ----------------------------------------------------------

bool rx_byte(const wire_t *w, uint8_t *out, uint32_t timeout_us)
{
    // Fast path: start bit (low) already on the line (before micros() since the call takes time).
    if (!is_line_high(w)) {
        return rx_byte_frame(w, out);
    }

     // time stamp (startzeit speichern)
    uint32_t start = micros();


    // Wait for falling edge (start bit) until the deadline. The unsigned
    while (true) {
        for (uint8_t line_check = 0; line_check < 8; line_check++) {  //leitung mehrfach schnell prüfen (line_check) und nur gelegentlich micros für das Timeout aufrufen
            if (!is_line_high(w)) {
                return rx_byte_frame(w, out);
            }
        }

        // check if past time is shorter than timeout 
        if ((uint32_t)(micros() - start) >= timeout_us) {
            return false;            // No start bit arrived before timeout expired
        }
    }
}


// ----------------------------------------------------------
// Receive byte after start bit was already detected
// ----------------------------------------------------------

bool rx_byte_frame(const wire_t *w, uint8_t *out)
{
    /*
     * scan_upstream() has already detected LOW.
     * double check if line is low -> if so, this should be the start bit.
     */

    _delay_us(BAUD_US / 2);

    if (is_line_high(w)) {
        return false;
    }

    /*
     * Move to middle of data bit 0.
     */
    _delay_us(BAUD_US);

    uint8_t b = 0;

    for (uint8_t i = 0; i < 8; i++) {
        if (is_line_high(w)) {
            b |= (1 << i);
        }

        _delay_us(BAUD_US);
    }

    // Stop bit check -> must be HIGH.
    if (!is_line_high(w)) {
        return false;
    }

    _delay_us(BAUD_US/2);

    *out = b;   // Write the value of b (stored bits) into the variable that out points to
    return true;
}

// ----------------------------------------------------------
// Frame Rolling checksum
// ----------------------------------------------------------

uint8_t calc_checksum(uint8_t payload_len, const uint8_t *payload)
{
    //Simple XOR checksum. Protected fields: LEN + PAYLOAD

    uint8_t checksum = payload_len;

    for (uint8_t i = 0; i < payload_len; i++) {
        checksum ^= payload[i];
    }

    return checksum;
}

//----------------------------------------------------
// Frame transmit
// Frame format:
// SYNC LEN PAYLOAD CRC
//----------------------------------------------------
void tx_frame(const wire_t *w, const uint8_t *payload, uint8_t payload_len){

    //calculate checksum for payload and payload_len
    uint8_t checksum = calc_checksum(payload_len, payload);

    tx_byte(w, SYNC_BYTE);
    tx_byte (w, payload_len);

    //transmit payload
    for (uint8_t i = 0; i < payload_len; i ++){
        tx_byte(w, payload[i]);
        //do i need here a delay for the parent to prove the data_frame?
    }

    //transmit CHECKSUM
    tx_byte(w, checksum);
    wire_release(w);
}

//----------------------------------------------------
// Frame Receive
// Receives SYNC LEN PAYLOAD CRC
//
// returns only:
// PAYLOAD and PAYLOAD_len
//----------------------------------------------------

bool rx_frame(
    const wire_t *w,
    uint8_t *payload,
    uint8_t max_payload_len,
    uint8_t *payload_len,
    uint32_t frame_timeout_us,
    uint32_t inter_frame_timeout_us
)
{
    uint8_t sync = 0;

    SER_PRINTLN("RS");

    // Receive SYNC byte and check if it matches the expected one
    if (!rx_byte(w, &sync, frame_timeout_us)) {
        SER_PRINTLN("NS");
        return false;
    }

    if (sync != SYNC_BYTE) {
        SER_PRINTLN("WS");
        return false;
    }


    // Receive LEN byte and check if it is within the allowed range
    uint8_t len = 0;

    if (!rx_byte(w, &len, frame_timeout_us)) {
        SER_PRINTLN("TD");
        return false;
    }

    if (len > max_payload_len) {
        SER_PRINTLN("PL");
        return false;
    }

    // Receive PAYLOAD bytes
    for (uint8_t i = 0; i < len; i++) {   //repeat this loop for len times
        if (!rx_byte(w, &payload[i], inter_frame_timeout_us)) {
            SER_PRINTLN("WP");
            return false;
        }  
    }

    //receive CHECKSUM byte and validate it against the calculated checksum
    uint8_t received_checksum = 0;

    if (!rx_byte(w, &received_checksum, inter_frame_timeout_us)) {
        SER_PRINTLN("NCS");
        return false;
    }

    uint8_t calculated_checksum = calc_checksum(len, payload);

    if (received_checksum != calculated_checksum) {
        SER_PRINTLN("WCS");
        return false;
    }


    *payload_len = len; // write value of len to the variable tha payload_len points to
    return true;
}
