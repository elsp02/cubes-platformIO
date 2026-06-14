// testing payload senden über tx pin an computer

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
//#include "tree_parser.h"

// ------------------------------------------------------------
// Example payloads
// These are only the serialized tree payloads.
// SYNC, LEN and CHECKSUM are added by send_payload_to_pc().
// ------------------------------------------------------------

// Payload 0:
// A1
// ├─ B2
// │  └─ D4
// └─ C3
//    └─ E5
const uint8_t payload_0[] = {
    0xA1, 0x00, 0x03,
    0xB2, 0x01, 0x04,
    0xD4, 0x03, 0x00,
    0xC3, 0x02, 0x01,
    0xE5, 0x01, 0x00
};

// Payload 1:
// A1
// └─ B2
const uint8_t payload_1[] = {
    0xA1, 0x00, 0x01,
    0xB2, 0x01, 0x00
};

// Payload 2:
// A1
// ├─ B2
// ├─ C3
// └─ D4
const uint8_t payload_2[] = {
    0xA1, 0x00, 0x07,
    0xB2, 0x00, 0x00,
    0xC3, 0x01, 0x00,
    0xD4, 0x02, 0x00
};

// ------------------------------------------------------------
// Payload table
// ------------------------------------------------------------

struct Payloadlist {
    const uint8_t *data;
    uint8_t data_len;
};

const Payloadlist payloads[] = {
    { payload_0, sizeof(payload_0) },
    { payload_1, sizeof(payload_1) },
    { payload_2, sizeof(payload_2) }
};

const uint8_t PAYLOAD_COUNT = sizeof(payloads) / sizeof(payloads[0]);

uint8_t current_payload_index = 0;
//-----------------------------------------


uint8_t calculated_checksum(const uint8_t *payload, uint8_t len)
{
    uint8_t checksum = 0;

    for (uint8_t i = 0; i < len; i++) {
        checksum ^= payload[i];
    }

    return checksum;
}

void send_payload_to_pc(const uint8_t *payload, uint8_t payload_len)
{ 
    uint8_t checksum = calculated_checksum(payload, payload_len);

    Serial.write(SYNC_BYTE);
    Serial.write(payload_len);
    Serial.write(payload, payload_len); //why here payload_len again
    Serial.write(checksum);
}

void setup()
{
        /*
     * Use default Serial pins.
     * On ATtiny1616 with megaTinyCore:
     * TX = PB2
     * RX = PB3
     */
    Serial.begin(9600);
}

void loop()
{
    const Payloadlist *current_payload = &payloads[current_payload_index];
    
    send_payload_to_pc(current_payload -> data, current_payload -> data_len);
    current_payload_index++;

    if (current_payload_index >= PAYLOAD_COUNT){
        current_payload_index = 0;
    }

    delay(1000);
}