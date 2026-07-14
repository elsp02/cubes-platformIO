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

    *acked_out = false;

    /*
     * 1. Send CMD_STATUS to child.
     */
    tx_byte(w, CMD_STATUS);

    /*
     * 2. Switch direction: release the line and open the receive window
     * as early as possible. Listening early is harmless (start detection
     * is edge-triggered), and it gives the child's ACK timing ~200 us of
     * margin instead of racing our own TURNAROUND_US delay. One bit time
     * is enough for the pull-up to settle after release.
     */
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

    *acked_out = true;   // a child is definitely present on this port

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