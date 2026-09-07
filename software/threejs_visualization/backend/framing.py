"""
framing.py
- defines the binary frame format used between the PC/server and baseplate
- framing for the feedback payload which is sent to the baseplate
( used by feedback_output.py)
"""

# ----------------------------------------------------------
# Protocol bytes
# - single-byte commands
# - responses exchanged outside of a frame, used to control a session (start/stop, feedback status)
# ----------------------------------------------------------
SYNC = 0xA5 # marks the start of a DATA FRAME from the baseplate

CMD_START      = 0x53  # 'S' PC -> baseplate: start detection
CMD_STOP       = 0x58  # 'X' PC -> baseplate: stop sequence (all LEDs off), back to idle
RESP_DONE      = 0x44  # 'D' baseplate -> PC: feedback frame relayed, every cube confirmed
RESP_FB_FAILED = 0x4E  # 'N' baseplate -> PC: bad frame from PC or a cube failed to confirm


# ----------------------------------------------------------
# FEEDBACK FRAME framingfor baseplate 
# ----------------------------------------------------------

"""
build_frame
- wraps the feedback payload into a complete feedback frame SYNC | LEN | PAYLOAD | CHECKSUM
"""
def build_frame(payload: bytes) -> bytes:
    if len(payload) > 255:
        raise ValueError(f"Payload too long for 1-byte LEN field: {len(payload)}")

    payload_len = len(payload)
    return bytes([SYNC, payload_len]) + payload + bytes([calc_checksum(payload_len, payload)])


""" 
calc_checksum
- calculates the checksum for the frame 
"""
def calc_checksum(payload_len: int, payload: bytes) -> int:
    checksum = payload_len

    for byte in payload:
        checksum ^= byte

    return checksum

