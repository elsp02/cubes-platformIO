"""Binary frame format shared by all links: SYNC | LEN | PAYLOAD | CHECKSUM. -> Payload differs depending on the current situatiton (DATA, FEEDBACK, etc.)
    Protocoll Command bytes
"""

SYNC = 0xA5

# PC <-> baseplate command bytes 
CMD_START      = 0x53  # 'S' PC -> baseplate: start detection
CMD_STOP       = 0x58  # 'X' PC -> baseplate: stop sequence (all LEDs off), back to idle
RESP_DONE      = 0x44  # 'D' baseplate -> PC: feedback frame relayed, every cube confirmed
RESP_FB_FAILED = 0x4E  # 'N' baseplate -> PC: bad frame from PC or a cube failed to confirm


def calc_checksum(payload_len: int, payload: bytes) -> int:
    checksum = payload_len

    for byte in payload:
        checksum ^= byte

    return checksum

"""Wraps a payload into a complete SYNC | LEN | PAYLOAD | CHECKSUM frame."""
def build_frame(payload: bytes) -> bytes:
    if len(payload) > 255:
        raise ValueError(f"Payload too long for 1-byte LEN field: {len(payload)}")

    payload_len = len(payload)
    return bytes([SYNC, payload_len]) + payload + bytes([calc_checksum(payload_len, payload)])
