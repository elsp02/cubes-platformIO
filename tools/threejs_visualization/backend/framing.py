"""Binary frame format shared by all links: SYNC | LEN | PAYLOAD | CHECKSUM.

Pure module (no pyserial import) so the frame logic can be used and
tested without hardware. Mirrors calc_checksum in src/lib/wire_bus.cpp:
XOR over LEN and all payload bytes.
"""

SYNC = 0xA5

# PC <-> baseplate command bytes (mirror the PC_* defines in
# include/config.h; ASCII on purpose so the link can also be driven by
# hand in a serial monitor)
CMD_START      = 0x53  # 'S' PC -> baseplate: start detection
CMD_STOP       = 0x58  # 'X' PC -> baseplate: stop sequence, back to idle
FB_OK          = 0x41  # 'A' PC -> baseplate: feedback reply to a payload frame
RESP_DONE      = 0x44  # 'D' baseplate -> PC: correct feedback byte received
RESP_FB_FAILED = 0x4E  # 'N' baseplate -> PC: wrong feedback byte received


def calc_checksum(payload_len: int, payload: bytes) -> int:
    # XOR of LEN and every payload byte: any single flipped bit changes
    # the result, so receiver and sender computing different values
    # reveals a corrupted frame (cheap enough for an ATtiny)
    checksum = payload_len

    for byte in payload:
        checksum ^= byte

    return checksum


def build_frame(payload: bytes) -> bytes:
    """Wrap a payload into a complete SYNC | LEN | PAYLOAD | CHECKSUM frame."""
    if len(payload) > 255:
        raise ValueError(f"Payload too long for 1-byte LEN field: {len(payload)}")

    payload_len = len(payload)
    return bytes([SYNC, payload_len]) + payload + bytes([calc_checksum(payload_len, payload)])
