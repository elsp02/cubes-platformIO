"""PC-side driver for the UART building sequence test.

Counterpart to src/firmware_baseplate/uart_main_baseplate.cpp:

    PC -> baseplate : 'S' (START)   -> baseplate begins detection
    baseplate -> PC : payload frame SYNC | LEN | PAYLOAD | CHECKSUM
                      (first cycle always, then on change or heartbeat)
    PC -> baseplate : feedback frame (this test always sends the EMPTY
                      frame A5 00 00 = all LEDs off; the real feedback
                      comes from ws_server's compare result)
    baseplate -> PC : 'D' (done) or 'N' (feedback failed)
    ... repeats ...
    PC -> baseplate : 'X' (STOP) instead of feedback after the 5th
                      frame -> LEDs off, baseplate returns to idle

Usage:
    python handshake_test.py COM4 [115200]

Exit code 0 = sequence completed (5 frames + stop), 1 = failed.
"""
import os
import sys

import serial
from serial.tools import list_ports

# reuse the frame logic of the visualization backend (SYNC, checksum)
sys.path.insert(0, os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "..", "threejs_visualization", "backend",
))
from framing import (
    SYNC,
    calc_checksum,
    build_frame,
    CMD_START,
    CMD_STOP,
    RESP_DONE,
    RESP_FB_FAILED,
)

DEFAULT_PORT = "COM4"
DEFAULT_BAUD = 115200  # must match Serial.begin() in the firmware

# single source of truth for the byte values is framing.py
START_BYTE = bytes([CMD_START])
STOP_BYTE = bytes([CMD_STOP])
# protocol-layer test feedback: the EMPTY feedback frame (A5 00 00) is
# always valid and means "no cube listed" = all LEDs off
FEEDBACK_FRAME = build_frame(b"")
DONE_BYTE = bytes([RESP_DONE])
FB_FAILED_BYTE = bytes([RESP_FB_FAILED])

FRAMES_UNTIL_STOP = 5
REPLY_TIMEOUT_S = 2.0  # for the single status bytes
READ_TIMEOUT_S = 2.0   # per read while waiting for a frame (idle is normal)


def open_port(port: str, baud: int) -> serial.Serial:
    try:
        return serial.Serial(port, baud, timeout=READ_TIMEOUT_S)
    except serial.SerialException as error:
        print(f"Could not open {port}: {error}")
        if "PermissionError" in str(error) or "Zugriff" in str(error):
            print("Access denied usually means another program has the port "
                  "open (serial monitor, PlatformIO, Arduino IDE) - close it "
                  "and try again.")
        available = list(list_ports.comports())
        if available:
            print("Available ports:")
            for info in available:
                print(f"  {info.device} - {info.description}")
        else:
            print("No serial ports found at all - is the adapter plugged in "
                  "and its driver installed?")
        sys.exit(1)


def read_payload_frame(ser: serial.Serial) -> bytes:
    """Block until a valid SYNC | LEN | PAYLOAD | CHECKSUM frame arrives.

    Idle stretches are normal (the baseplate only sends on change or
    heartbeat), so timeouts while scanning just print a waiting note.
    Broken frames (timeout mid-frame, checksum error) are reported and
    scanning starts over.
    """
    while True:
        # scan byte-wise for SYNC
        byte = ser.read(1)

        if not byte:
            print("  ... waiting for payload frame (idle is normal) ...")
            continue

        if byte[0] != SYNC:
            print(f"  skipping unexpected byte 0x{byte[0]:02X}")
            continue

        # SYNC found: read LEN, PAYLOAD, CHECKSUM
        len_byte = ser.read(1)
        if not len_byte:
            print("  timeout after SYNC, resyncing")
            continue
        payload_len = len_byte[0]

        payload = ser.read(payload_len)
        if len(payload) != payload_len:
            print(f"  timeout in payload: expected {payload_len} bytes, "
                  f"got {len(payload)}, resyncing")
            continue

        checksum_byte = ser.read(1)
        if not checksum_byte:
            print("  timeout before checksum, resyncing")
            continue

        expected = calc_checksum(payload_len, payload)
        if checksum_byte[0] != expected:
            print(f"  checksum error (got 0x{checksum_byte[0]:02X}, "
                  f"expected 0x{expected:02X}), frame ignored")
            continue

        return payload


def exchange_feedback(ser: serial.Serial) -> None:
    """Send the (empty) feedback frame and report the status reply."""
    ser.write(FEEDBACK_FRAME)
    print(f"  sent empty feedback frame {FEEDBACK_FRAME.hex(' ')}")

    reply = ser.read(1)

    if not reply:
        print(f"  WARNING: no status byte within {REPLY_TIMEOUT_S:.0f} s")
    elif reply == DONE_BYTE:
        print("  baseplate confirmed: D (feedback relayed)")
    elif reply == FB_FAILED_BYTE:
        print("  WARNING: baseplate reports feedback failure (N)")
    else:
        print(f"  WARNING: unexpected status byte 0x{reply[0]:02X}")


def main() -> None:
    port = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PORT
    baud = int(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_BAUD

    with open_port(port, baud) as ser:
        print(f"Connected to {port} at {baud} baud.")
        ser.reset_input_buffer()

        # start the building sequence on the baseplate
        ser.write(START_BYTE)
        print(f"Sent START '{START_BYTE.decode()}' - baseplate should begin "
              f"detection.")

        for frame_number in range(1, FRAMES_UNTIL_STOP + 1):
            payload = read_payload_frame(ser)

            if payload:
                print(f"Frame {frame_number}/{FRAMES_UNTIL_STOP}: "
                      f"payload = {payload.hex(' ')} (len={len(payload)})")
            else:
                print(f"Frame {frame_number}/{FRAMES_UNTIL_STOP}: "
                      f"empty payload (len=0) - nothing detected")

            if frame_number < FRAMES_UNTIL_STOP:
                exchange_feedback(ser)
            else:
                # 5th frame: stop instead of feedback
                ser.write(STOP_BYTE)
                print(f"Sent STOP '{STOP_BYTE.decode()}' after frame "
                      f"{FRAMES_UNTIL_STOP}.")

    print("Sequence completed: baseplate is idle again, waiting for the "
          "next START.")


if __name__ == "__main__":
    main()
