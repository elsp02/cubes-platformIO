// Minimal UART handshake test - no wire bus, no framing, no tree logic.
//
// Proves both UART directions between PC and ATtiny1616 through a
// TTL adapter:
//
//   PC -> ATtiny : 'S' (START)
//   ATtiny -> PC : 'A' (ACK)
//   PC -> ATtiny : 'F' (FEEDBACK)
//   ATtiny -> PC : 'D' (DONE)
//
// All bytes are printable ASCII, so the firmware can also be tested by
// hand in any serial monitor at 115200 baud: type S, see A, type F, see D.
//
// Serial is the hardware USART0. Serial.begin() configures the pins
// itself - defaults on the ATtiny1616: TX = PB2, RX = PB3.

#include <Arduino.h>

static const uint8_t START_BYTE    = 'S';
static const uint8_t ACK_BYTE      = 'A';
static const uint8_t FEEDBACK_BYTE = 'F';
static const uint8_t DONE_BYTE     = 'D';

// how long to wait for the feedback byte before giving up and
// listening for a new START again
static const unsigned long FEEDBACK_TIMEOUT_MS = 2000;

void setup()
{
    Serial.begin(115200);
}

void loop()
{
    // ---- state 1: wait for START (ignore everything else) ----
    if (Serial.available() == 0) {
        return;
    }
    if (Serial.read() != START_BYTE) {
        return;
    }

    Serial.write(ACK_BYTE);

    // ---- state 2: wait for FEEDBACK, with timeout ----
    unsigned long started_waiting = millis();

    while (millis() - started_waiting < FEEDBACK_TIMEOUT_MS) {
        if (Serial.available() == 0) {
            continue;
        }
        if (Serial.read() == FEEDBACK_BYTE) {
            Serial.write(DONE_BYTE);
            return;   // handshake complete, back to waiting for START
        }
        // wrong byte: keep waiting until the timeout runs out
    }

    // timeout: send nothing, fall back to waiting for START so a
    // half-finished handshake cannot wedge the device
}