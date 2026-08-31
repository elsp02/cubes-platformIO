// everything for serial writing
#include "config.h"
#include "serial_writing.h"

#include <util/delay.h>
//-----------------------------------------------------------
// Serial Writing
//-----------------------------------------------------------


static uint8_t last_sent_payload[MAX_PAYLOAD_LEN];
static uint8_t last_sent_payload_len = 0;
static bool have_sent_before = false;   // so the very first valid payload always gets sent

// Returns true if `payload` (length `payload_len`) differs from
// whatever was last sent.
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

// remebers the last sent payload - for checking if payload has changed
void remember_sent_payload(const uint8_t *payload, uint8_t payload_len)
{
    for (uint8_t i = 0; i < payload_len; i++) {
        last_sent_payload[i] = payload[i];
    }
    last_sent_payload_len = payload_len;
    have_sent_before = true;
}


//------------------------------
// error message buffer
//------------------------------
static char log_buffer[LOG_BUF_SIZE];
static uint16_t log_length = 0;


// Clear the buffer at the beginning of a detection cycle
void log_reset(void)
{
    log_length = 0;
}


// Add text without a line break
void log_append(const char *message)
{
    while (*message != '\0' && log_length < LOG_BUF_SIZE) {
        log_buffer[log_length++] = *message++;
    }
}


// Add text with the same line ending as Serial.println()
void log_appendln(const char *message)
{
    log_append(message);
    log_append("\r\n");
}

void log_append(uint32_t value, uint8_t base)
{
    char number_buffer[33];

    // Convert number into text.
    // Maximum size is 32 binary digits plus '\0'.
    ultoa(value, number_buffer, base);

    log_append(number_buffer);
}


void log_appendln(uint32_t value, uint8_t base)
{
    log_append(value, base);
    log_append("\r\n");
}

// Print everything stored in the buffer
void log_flush(void)
{
    if (log_length > 0) {
        Serial.write(
            reinterpret_cast<const uint8_t *>(log_buffer),
            log_length
        );
    }
}
