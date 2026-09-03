// =====================================================================
// serial_writing.cpp
// - payload-change tracking (baseplate: skips resending an unchanged detection frame)
// 
// currently not used:
//- buffered debug log, used when SERIAL_DEBUG_END is active (config.h)
// =====================================================================
#include "config.h"
#include "serial_writing.h"

#include <util/delay.h>

// ----------------------------------------------------------
// Payload Change Tracking for Baseplate
// - remembers the last payload sent to the PC, to avoid resending an
//   unchanged detection frame every cycle
// ----------------------------------------------------------
static uint8_t last_sent_payload[MAX_PAYLOAD_LEN];
static uint8_t last_sent_payload_len = 0;
static bool have_sent_before = false;   // so the very first valid payload always gets sent

// payload_changed
// - true if payload differs from whatever was last sent
bool payload_changed(const uint8_t *payload, uint8_t payload_len)
{
    if (!have_sent_before) {
        return true;   // nothing sent yet — always send the first valid reading
    }

    if (payload_len != last_sent_payload_len) {
        return true;
    }

    for (uint8_t i = 0; i < payload_len; i++) {
        if (payload[i] != last_sent_payload[i]) {
            return true;
        }
    }

    return false;   // identical to last time
}

// remember_sent_payload
// - stores payload as the new "last sent" baseline for for checking if payload has changed in payload_changed()
void remember_sent_payload(const uint8_t *payload, uint8_t payload_len)
{
    for (uint8_t i = 0; i < payload_len; i++) {
        last_sent_payload[i] = payload[i];
    }
    last_sent_payload_len = payload_len;
    have_sent_before = true;
}


// ----------------------------------------------------------
// Debug Log Buffer - currently not in use
// - in-RAM buffer, flushed to Serial in one write instead of many small ones
// ----------------------------------------------------------
static char log_buffer[LOG_BUF_SIZE];
static uint16_t log_length = 0;


// log_reset
// - clears the buffer, e.g. at the start of a detection cycle
void log_reset(void)
{
    log_length = 0;
}


// log_append
// - appends text, without a line break
void log_append(const char *message)
{
    while (*message != '\0' && log_length < LOG_BUF_SIZE) {
        log_buffer[log_length++] = *message++;
    }
}


// log_appendln
// - appends text with the same line ending as Serial.println()
void log_appendln(const char *message)
{
    log_append(message);
    log_append("\r\n");
}

// log_append (numeric overload)
// - converts value to text in the given base, then appends it
void log_append(uint32_t value, uint8_t base)
{
    char number_buffer[33];

    // Convert number into text.
    // Maximum size is 32 binary digits plus '\0'.
    ultoa(value, number_buffer, base);

    log_append(number_buffer);
}

// log_appendln (numeric overload)
void log_appendln(uint32_t value, uint8_t base)
{
    log_append(value, base);
    log_append("\r\n");
}

// log_flush
// - writes everything stored in the buffer to Serial in one
void log_flush(void)
{
    if (log_length > 0) {
        Serial.write(
            reinterpret_cast<const uint8_t *>(log_buffer),
            log_length
        );
    }
}
