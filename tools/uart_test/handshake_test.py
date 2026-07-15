"""Minimal UART handshake test, PC side.

Counterpart to src/firmware_test/main_uart_handshake.cpp:

    PC -> ATtiny : 'S' (START)
    ATtiny -> PC : 'A' (ACK)
    PC -> ATtiny : 'F' (FEEDBACK)
    ATtiny -> PC : 'D' (DONE)

Usage:
    python handshake_test.py COM4 [115200]

Exit code 0 = handshake PASSED, 1 = FAILED.
"""
import sys

import serial
from serial.tools import list_ports

DEFAULT_PORT = "COM4"
DEFAULT_BAUD = 115200  # must match Serial.begin() in the test firmware

START_BYTE = b"S"
ACK_BYTE = b"A"
FEEDBACK_BYTE = b"F"
DONE_BYTE = b"D"

STEP_TIMEOUT_S = 2.0


def open_port(port: str, baud: int) -> serial.Serial:
    try:
        return serial.Serial(port, baud, timeout=STEP_TIMEOUT_S)
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


def expect_byte(ser: serial.Serial, expected: bytes, step_name: str) -> bool:
    """Read one byte and check it. Prints what actually happened."""
    received = ser.read(1)

    if not received:
        print(f"  FAIL: no {step_name} received within "
              f"{STEP_TIMEOUT_S:.0f} s (timeout)")
        return False

    if received != expected:
        print(f"  FAIL: expected {step_name} "
              f"{expected.decode()} (0x{expected[0]:02X}), "
              f"got 0x{received[0]:02X}")
        return False

    print(f"  OK: received {step_name} {received.decode()} "
          f"(0x{received[0]:02X})")
    return True


def main() -> None:
    port = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PORT
    baud = int(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_BAUD

    with open_port(port, baud) as ser:
        print(f"Connected to {port} at {baud} baud.")
        ser.reset_input_buffer()

        print(f"Step 1: sending START '{START_BYTE.decode()}'")
        ser.write(START_BYTE)

        if not expect_byte(ser, ACK_BYTE, "ACK"):
            print("Handshake FAILED.")
            sys.exit(1)

        print(f"Step 2: sending FEEDBACK '{FEEDBACK_BYTE.decode()}'")
        ser.write(FEEDBACK_BYTE)

        if not expect_byte(ser, DONE_BYTE, "DONE"):
            print("Handshake FAILED.")
            sys.exit(1)

    print("Handshake PASSED: both UART directions work.")


if __name__ == "__main__":
    main()
