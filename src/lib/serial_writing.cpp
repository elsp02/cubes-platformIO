// everything for serial writing
#include "config.h"

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

// Call only AFTER you've decided to actually send — updates the snapshot.
void remember_sent_payload(const uint8_t *payload, uint8_t payload_len)
{
    for (uint8_t i = 0; i < payload_len; i++) {
        last_sent_payload[i] = payload[i];
    }
    last_sent_payload_len = payload_len;
    have_sent_before = true;
}

//----------------------------------------------------
// for log_line
//----------------------------------------------------
static char log_buf[LOG_BUF_SIZE];
static uint8_t log_len = 0;

static void log_line(const char *msg)
{
    uint8_t i = 0;
    while (msg[i] != '\0' && log_len < LOG_BUF_SIZE - 2) {
        log_buf[log_len++] = msg[i++];
    }
    if (log_len < LOG_BUF_SIZE - 1) {
        log_buf[log_len++] = '\n';
    }
}

static void log_flush(void)
{
    if (log_len > 0) {
        Serial.write((const uint8_t *)log_buf, log_len);
        log_len = 0;
    }
}