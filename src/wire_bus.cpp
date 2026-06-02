// enthält allgemeinen Bus Treiber und keine konkrete Hardwarebelegung (damit die Funktionen von allen Modulen genutzt werden können)
// -> wie art schablone bzw lückentext und das spezielle wird dann in den Modulen definiert

#include "config.h"
#include "wire_bus.h"

#include <util/delay.h>

// ----------------------------------------------------------
// Wire primitives
// ----------------------------------------------------------

void wire_release(const wire_t *w)
{
    /*
     * Logic high:
     * release the line and enable internal pull-up.
     */
    w->port->OUTCLR = w->pin_bm;
    w->port->DIRCLR = w->pin_bm;

    switch (w->pin_idx) {
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
    /*
     * Logic low:
     * actively pull line to GND.
     */
    w->port->OUTCLR = w->pin_bm;
    w->port->DIRSET = w->pin_bm;
}

//suggestion: rename to is_line_high() to make it more clear that it returns a boolean value
bool line_high(const wire_t *w)
{
    return (w->port->IN & w->pin_bm) != 0;
}

// ----------------------------------------------------------
// Byte transmit
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
// ----------------------------------------------------------

bool rx_byte(const wire_t *w, uint8_t *out, uint16_t timeout_us)
{
    /*
     * Wait for falling edge.
     * One loop iteration waits 10 µs.
     */
    while (line_high(w)) {
        if (timeout_us < 10) {
            return false;
        }

        timeout_us -= 10;
        _delay_us(10);
    }

    /*
     * Validate start bit in the middle of the start bit.
     */
    _delay_us(BAUD_US / 2);

    if (line_high(w)) {
        return false;
    }

    //suggestion: call rx_byte_after_start_detected() here to avoid code duplication

    /*
     * Move to middle of data bit 0.
     */
    _delay_us(BAUD_US);

    uint8_t b = 0;

    for (uint8_t i = 0; i < 8; i++) {
        if (line_high(w)) {
            b |= (1 << i);
        }

        _delay_us(BAUD_US);
    }

    /*
     * Stop bit must be HIGH.
     */
    if (!line_high(w)) {
        return false;
    }

    _delay_us(BAUD_US);


    *out = b;
    return true;
}

// ----------------------------------------------------------
// Receive byte after start bit was already detected
// ----------------------------------------------------------

bool rx_byte_after_start_detected(const wire_t *w, uint8_t *out)
{
    /*
     * scan_upstream() has already detected LOW.
     * This should be the start bit.
     */

    _delay_us(BAUD_US / 2);

    if (line_high(w)) {
        return false;
    }

    /*
     * Move to middle of data bit 0.
     */
    _delay_us(BAUD_US);

    uint8_t b = 0;

    for (uint8_t i = 0; i < 8; i++) {
        if (line_high(w)) {
            b |= (1 << i);
        }

        _delay_us(BAUD_US);
    }

    /*
     * Stop bit must be HIGH.
     */
    bool stop_ok = line_high(w);
    _delay_us(BAUD_US / 2);

    if (!stop_ok) {
        return false;
    }

    *out = b;
    return true;
}