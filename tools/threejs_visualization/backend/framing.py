"""Binary frame format shared by all links: SYNC | LEN | PAYLOAD | CHECKSUM.

Pure module (no pyserial import) so the frame logic can be used and
tested without hardware. Mirrors calc_checksum in src/lib/wire_bus.cpp:
XOR over LEN and all payload bytes.
"""

SYNC = 0xA5


def calc_checksum(payload_len: int, payload: bytes) -> int:
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
