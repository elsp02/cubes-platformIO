"""Serial tree source: enables communication between reader/server and hardware (baseplate)

building-sequence protocol:

    PC -> baseplate : CMD_START ('S')   baseplate begins detection
    baseplate -> PC : payload frame  SYNC | LEN | PAYLOAD | CHECKSUM
                      (first cycle always, then on change or heartbeat)
    PC -> baseplate : FEEDBACK FRAME (same SYNC|LEN|PAYLOAD|CHECKSUM
                      format, payload = [NODE_ID, LED_STATE] pairs from
                      the compare result), answered for EVERY frame
    baseplate -> PC : RESP_DONE ('D') when every cube confirmed the
                      relayed feedback, RESP_FB_FAILED ('N') otherwise
    PC -> baseplate : CMD_STOP ('X')    on shutdown; the baseplate then
                      relays an empty frame (all LEDs off) and idles

connection to ws_server.py: iter_trees_from_binary_serial() -> ws_server.py runs it in a worker thread and consumes the yielded trees
"""
import threading
from typing import Callable, Optional

import serial

from cube_node import CubeNode
from payload_parser import parse_tree
from framing import (
    SYNC,
    calc_checksum,
    build_frame,
    CMD_START,
    CMD_STOP,
    RESP_DONE,
    RESP_FB_FAILED,
)


"""
    Reads the rest of a data frame (LEN | PAYLOAD | CHECKSUM) after a
    valid SYNC byte has already been consumed by the caller.

    Returns the payload bytes, or None if the frame was broken (timeout in the middle of the frame, or checksum mismatch)

    same structure as in hardware rx_frame
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
    transmits on change) -> Returns True if SYNC was found, False on idle timeout.

    same structure as in hardware wait_for_valid_sync_cmd()
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
    Answers a payload frame: sends the complete feedback frame and
    checks the baseplate's status reply.

    The firmware waits up to PC_REPLY_TIMEOUT_MS for this reply after EVERY frame it sends (heartbeats included)
"""
def send_feedback_frame(ser: serial.Serial, frame: bytes, verbose: bool) -> None:

    ser.write(frame)

    status = ser.read(1)

    if not status:
        if verbose:
            print("No status byte from baseplate (timeout).")
    elif status[0] == RESP_DONE:
        pass    # normal case: every cube confirmed the feedback
    elif status[0] == RESP_FB_FAILED:
        print("Baseplate reports feedback failure (bad frame or a cube "
              "did not confirm).")
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
    port: str, 
    baudrate: int = 115200,  # must match Serial.begin() in the firmware
    verbose: bool = True,   # False silences the idle/resync/heartbeat chatter

    # builds the feedback frame for a tree (None = nothing built);
    # supplied by ws_server so this file needs no compare/target imports
    feedback_builder: Optional[Callable[[Optional[CubeNode]], bytes]] = None,

    # set from another thread to end the session: the loop checks it once
    # per iteration, so the reader stops within ~1 s (the serial timeout)
    # even when the line is idle; the finally block then sends CMD_STOP
    stop_event: Optional[threading.Event] = None,
):


    with serial.Serial(port, baudrate, timeout=1) as ser:
        # drop any stale bytes still buffered from a previous run, so the
        # first frame we parse really belongs to this session
        ser.reset_input_buffer()

        # send CMD Start: baseplate starts with its program
        ser.write(bytes([CMD_START]))
        print(f"Connected to {port} at {baudrate} baud, START sent.")

        # without a builder (standalone use) every frame is answered with
        # the empty feedback frame = all LEDs off
        if feedback_builder is None:
            feedback_builder = lambda tree: build_frame(b"")

        last_payload: Optional[bytes] = None         # snapshot of last answered payload
        last_feedback_frame: Optional[bytes] = None  # its frame, resent on heartbeats

        # START can get lost when sessions follow each other quickly:
        # the firmware's stop_received() drains its WHOLE input buffer
        # while processing the previous session's STOP, eating a START
        # that is already buffered behind it - the baseplate then idles
        # forever. But after a successful START the firmware always
        # sends a frame within its first cycle, so silence before the
        # FIRST sync byte means the START never arrived -> resend it.
        got_first_sync = False
        idle_timeouts_since_start = 0

        try:
            while True:
                # look for session ended info (end_session message or browser disconnect from client)?
                if stop_event is not None and stop_event.is_set():
                    break

                # scan for the start of the next frame; False = 1 s passed
                # with no bytes at all (normal while the tower is unchanged)
                found_sync = wait_for_valid_sync_cmd(ser, verbose)

                if not found_sync:
                    if verbose:
                        print("Idle: no data received in the last second.")

                    if not got_first_sync:
                        idle_timeouts_since_start += 1
                        if idle_timeouts_since_start >= 3:
                            # harmless if the baseplate IS running: in
                            # idle it only reacts to START anyway, and
                            # while running it would have sent a frame
                            # long before 3 s of silence
                            ser.write(bytes([CMD_START]))
                            idle_timeouts_since_start = 0
                            print("No frame since START - START sent again.")

                    continue            # keep scanning for the next SYNC

                got_first_sync = True   # baseplate is talking, START arrived

                payload = rx_frame(ser)
                if payload is None:
                    continue   # broken frame: no reply, firmware's own timeout covers it

                # heartbeat = identical payload sent again just to show the
                # link is alive; the compare result would be identical too,
                # so resend the cached feedback frame (EVERY frame must be
                # answered - the firmware blocks waiting for it) and yield
                # nothing new
                if payload == last_payload and last_feedback_frame is not None:
                    if verbose:
                        print("Heartbeat")
                    send_feedback_frame(ser, last_feedback_frame, verbose)
                    continue

                print(f"DEBUG payload: {payload.hex(' ')} (len={len(payload)})")

                # payload -> tree; empty payload (LEN 0) = nothing detected
                # -> None ("nothing built")
                if len(payload) == 0:
                    tree: Optional[CubeNode] = None
                else:
                    try:
                        tree = parse_tree(payload)

                    except ValueError as error:
                        print(f"Parser error: {error}")
                        print(f"Payload: {payload.hex(' ')}")
                        ser.reset_input_buffer()
                        continue

                # answer the frame with the feedback derived from this tree
                feedback_frame = feedback_builder(tree)
                send_feedback_frame(ser, feedback_frame, verbose)

                # update the snapshots only after a fully successful exchange
                last_payload = payload
                last_feedback_frame = feedback_frame

                yield tree   # hand the tree to the consumer, pause here

        finally:
            # on generator close or error: send CMD Stop: the baseplate back to idle
            try:
                ser.write(bytes([CMD_STOP]))
            except serial.SerialException:
                pass
