"""Serial tree source: talks to the real baseplate over the UART link.

Position in the pipeline:

    baseplate firmware (uart_main_baseplate.cpp)
        --serial--> THIS FILE --> CubeNode tree --> ws_server.py

Implements the PC side of the building-sequence protocol:

    PC -> baseplate : CMD_START ('S')   baseplate begins detection
    baseplate -> PC : payload frame  SYNC | LEN | PAYLOAD | CHECKSUM
                      (first cycle always, then on change or heartbeat)
    PC -> baseplate : FB_OK ('A')       feedback byte, answered for EVERY frame
    baseplate -> PC : RESP_DONE ('D') or RESP_FB_FAILED ('N')
    PC -> baseplate : CMD_STOP ('X')    on shutdown, baseplate goes back to idle

The main entry point is iter_trees_from_binary_serial() at the bottom;
ws_server.py runs it in a worker thread and consumes the yielded trees.
"""
from typing import Optional

import serial

from cube_node import CubeNode
from payload_parser import parse_tree
from framing import (
    SYNC,
    calc_checksum,
    CMD_START,
    CMD_STOP,
    FB_OK,
    RESP_DONE,
    RESP_FB_FAILED,
)


"""
    Reads the rest of a data frame (LEN | PAYLOAD | CHECKSUM) after a
    valid SYNC byte has already been consumed by the caller.

    Returns the payload bytes, or None if the frame was broken
    (timeout in the middle of the frame, or checksum mismatch).
    On any failure the input buffer is flushed so no half-frame bytes
    are left behind to misalign the next read.
"""
def rx_frame(ser:serial.Serial) ->Optional[bytes]:

        # ser.read(1) blocks for at most `timeout` seconds (set when the
        # port was opened); [0] converts the 1-byte bytes object to an int
        payload_len = ser.read(1)[0]


        payload= ser.read(payload_len)
        if len(payload) != payload_len:
            # read() returned fewer bytes than requested = timeout mid-frame
            print(f"Timeout reading payload: expected {payload_len}, got {len(payload)}.")
            ser.reset_input_buffer()
            return None

        received_checksum = ser.read(1)[0]

        # recompute the checksum over LEN + payload and compare with the
        # one the sender attached (same XOR algorithm as in wire_bus.cpp)
        calculated_checksum = calc_checksum(payload_len, payload)

        if received_checksum != calculated_checksum:
            print("Checksum error. Frame ignored.")
            print(f"Received checksum:   0x{received_checksum:02X}")
            print(f"Calculated checksum: 0x{calculated_checksum:02X}")
            print(f"Payload: {payload.hex(' ')}")
            ser.reset_input_buffer()
            return None
        return payload


"""
    Reads single bytes until a SYNC byte is found, or the read times out
    with nothing arriving at all (idle = normal, since the sender only
    transmits on change).

    Returns True if SYNC was found, False on idle timeout.

    This byte-by-byte scanning is what re-aligns the reader after a
    broken frame: any leftover bytes are consumed and reported here
    until the next real frame start (SYNC) comes along.
"""
def wait_for_valid_sync_cmd(ser: serial.Serial, verbose: bool) -> bool:

    while True:
        b = ser.read(1)   # reads exactly one byte (or nothing on timeout)

        if not b:
            return False   # idle timeout, nothing arrived at all

        if b[0] == SYNC:   # arrived byte is correct SYNC byte
            return True

        if verbose:
            print(f"Skipping unexpected byte while resyncing: 0x{b[0]:02X}")


"""
    Answers a payload frame: sends the feedback byte (placeholder 'A'
    for now) and checks the baseplate's status reply.

    The firmware waits up to PC_REPLY_TIMEOUT_MS for this reply after
    EVERY frame it sends (heartbeats included), so this must be called
    for every valid frame - otherwise each frame stalls for 2 seconds.
    A missing/wrong status byte is only reported, never fatal.
"""
def confirm_frame(ser: serial.Serial, verbose: bool) -> None:

    ser.write(bytes([FB_OK]))

    status = ser.read(1)

    if not status:
        if verbose:
            print("No status byte from baseplate (timeout).")
    elif status[0] == RESP_DONE:
        pass    # normal case: feedback byte accepted
    elif status[0] == RESP_FB_FAILED:
        print("Baseplate reports wrong feedback byte (N).")
    elif verbose:
        print(f"Unexpected status byte: 0x{status[0]:02X}")


"""
    Main function: starts the baseplate and continuously turns its
    binary frames into CubeNode trees.

    This is a GENERATOR: `yield tree` hands one tree to the caller
    (the for-loop in ws_server.py's tree_worker) and pauses here until
    the caller asks for the next one. So the while-loop below runs
    "lazily", one tree per consumer iteration, without ever returning.

    Frame:
    SYNC | LEN | PAYLOAD | CHECKSUM

    The sender only transmits a frame when its payload has actually
    changed (plus a periodic heartbeat), so long stretches with no
    bytes at all are the normal, expected case -- not an error.

    Any failure partway through a frame (timeout, checksum mismatch,
    or parse error) flushes the input buffer and falls back to
    byte-by-byte SYNC scanning, so a broken/partial frame can never
    leave stray bytes behind to misalign the next read.
"""
def iter_trees_from_binary_serial(
    port: str,  # port defined as string, e.g. "COM3"
    baudrate: int = 115200,  # must match Serial.begin() in the firmware
    verbose: bool = True,   # False silences the idle/resync/heartbeat chatter
):


    with serial.Serial(port, baudrate, timeout=1) as ser:
        # drop any stale bytes still buffered from a previous run, so the
        # first frame we parse really belongs to this session
        ser.reset_input_buffer()

        # the baseplate idles until it receives the start command
        ser.write(bytes([CMD_START]))
        print(f"Connected to {port} at {baudrate} baud, START sent.")

        last_payload: Optional[bytes] = None   # snapshot of last answered payload

        try:
            while True:
                # scan for the start of the next frame; False = 1 s passed
                # with no bytes at all (normal while the tower is unchanged)
                found_sync = wait_for_valid_sync_cmd(ser, verbose)

                if not found_sync:
                    if verbose:
                        print("Idle: no data received in the last second.")
                    continue            # keep scanning for the next SYNC

                payload = rx_frame(ser)
                if payload is None:
                    continue   # broken frame: no reply, firmware's own timeout covers it

                # answer EVERY valid frame (heartbeats too) - the firmware
                # blocks waiting for the feedback byte after each frame
                confirm_frame(ser, verbose)

                # heartbeat = identical payload sent again just to show the
                # link is alive; already answered above, nothing new to yield
                if payload == last_payload:
                    if verbose:
                        print("Heartbeat")
                    continue

                last_payload = payload   # update snapshot before yielding
                print(f"DEBUG payload: {payload.hex(' ')} (len={len(payload)})")

                # empty payload (LEN 0) = nothing detected -> "nothing built",
                # same as the simulated story's first step
                if len(payload) == 0:
                    yield None
                    continue

                #parse payload to tree
                try:
                    tree: CubeNode = parse_tree(payload)
                    yield tree   # hand the tree to the consumer, pause here

                except ValueError as error:
                    # parse_tree raises ValueError when the payload does not
                    # form a valid tree (truncated node header, child_mask
                    # promising children that are missing, leftover bytes)
                    print(f"Parser error: {error}")
                    print(f"Payload: {payload.hex(' ')}")
                    ser.reset_input_buffer()

        finally:
            # on generator close or error: send the baseplate back to idle
            # (best effort - if this never runs, the firmware survives via
            # its reply timeout and the next START flushes stray state)
            try:
                ser.write(bytes([CMD_STOP]))
            except serial.SerialException:
                pass
