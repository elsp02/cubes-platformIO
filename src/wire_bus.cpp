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

bool is_line_high(const wire_t *w)
    /**
     * checks if the line is high (returns true if high)
     */
{
    return (w->port->IN & w->pin_bm) != 0;
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
// brauch ich bei rx_byte definition das uint8_t *out?
// ----------------------------------------------------------

bool rx_byte(const wire_t *w, uint8_t *out, uint16_t timeout_us)
{
    /*
     * Wait for falling edge.
     * One loop iteration waits 10 µs.
     */
    while (is_line_high(w)) {
        if (timeout_us < 10) {
            return false;
        }

        timeout_us -= 10;
        _delay_us(10);
    }

    return rx_byte_data_frame(w, out);
}

// ----------------------------------------------------------
// Receive byte after start bit was already detected
// ----------------------------------------------------------

bool rx_byte_data_frame(const wire_t *w, uint8_t *out)
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

    /*
     * Stop bit must be HIGH.
     */
    if (!is_line_high(w)) {
        return false;
    }

    _delay_us(BAUD_US); // vlt _delay_us(BAUD_US/2) oder stop bit wie start bit zweimal abfragen?

    *out = b;
    return true;
}