// Schnittstelle der Bus-/Leitungsfunktionen
#ifndef WIRE_BUS_H
#define WIRE_BUS_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

// ----------------------------------------------------------
// wire_t — single-wire open-drain line descriptor
// each wire_t stores 3 infos 
// port    : pointer to the AVR PORT struct (e.g. &PORTA, &PORTB)
//  pin_bm  : bitmask of the pin  (e.g. PIN1_bm)
//  pin_idx : numeric index 0-7, used to select PINnCTRL for pull-up
// ----------------------------------------------------------

typedef struct {
    PORT_t  *port;
    uint8_t  pin_bm;
    uint8_t  pin_idx;
} wire_t;

// ----------------------------------------------------------
// Wire primitives
// examples:
// line_release(const wire_t *w)  = function definition
// line_release(&upstream)       = function call with &upstream pin defined in wire_t as argument
// ----------------------------------------------------------

void wire_release(const wire_t *w); // releases the line (high level)
void wire_low(const wire_t *w);     // pulls the line low (low level)
bool is_line_high(const wire_t *w); // checks if the line is high (returns true if high)

// ----------------------------------------------------------
// UART-like byte transfer
// ----------------------------------------------------------

void tx_byte(const wire_t *w, uint8_t b);  //transmission of byte

bool rx_byte(                              // receiving of byte
    const wire_t *w,
    uint8_t *out,
    uint16_t timeout_us
);

bool rx_byte_data_frame(                   //receiving of message (sent bits) without start bit
    const wire_t *w,
    uint8_t *out
);

#endif