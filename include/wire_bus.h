// Schnittstelle der Bus-/Leitungsfunktionen
#ifndef WIRE_BUS_H
#define WIRE_BUS_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

// ----------------------------------------------------------
// wire_t — single-wire open-drain line descriptor
// ----------------------------------------------------------

typedef struct {
    PORT_t  *port;
    uint8_t  pin_bm;
    uint8_t  pin_idx;
} wire_t;

// ----------------------------------------------------------
// Wire primitives
// ----------------------------------------------------------

void wire_release(const wire_t *w);
void wire_low(const wire_t *w);
bool line_high(const wire_t *w);

// ----------------------------------------------------------
// UART-like byte transfer
// ----------------------------------------------------------

void tx_byte(const wire_t *w, uint8_t b);

bool rx_byte(
    const wire_t *w,
    uint8_t *out,
    uint16_t timeout_us
);

bool rx_byte_after_start_detected(
    const wire_t *w,
    uint8_t *out
);

#endif