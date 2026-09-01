#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"

#include <util/delay.h>
// ----------------------------------------------------------
// Poll one child port
// ----------------------------------------------------------

bool poll_child(const wire_t *w, uint8_t *data_out, uint8_t max_child_payload_len, uint8_t *child_payload_len, bool *acked_out)
{
    uint8_t b = 0;

    // to check if a child is definitely present on this port - because if so, full retry round if not, just one polling try
    *acked_out = false;

    /*
     * 1. Send CMD_STATUS to child.
     */
    tx_byte(w, CMD_STATUS);

    wire_release(w);
    _delay_us(BAUD_US);

    /*
     * 3. Wait for ACK_BUSY.
     */
    if (!rx_byte(w, &b, CHILD_TIMEOUT_US)) {
        SER_PRINTLN("NA");
        return false;
    }

    if (b != ACK_BUSY) {
        SER_PRINTLN("WA");
        return false;
    }

    *acked_out = true;   

    //SER_PRINT("CA");
    /*
     * 4. ACK received, now wait for child data byte.
     */
    if (!rx_frame(
            w,
            data_out,
            max_child_payload_len,
            child_payload_len,
            FRAME_TIMEOUT_US,
            INTER_FRAME_TIMEOUT_US
        )) {
        return false;
    }

    return true;
}