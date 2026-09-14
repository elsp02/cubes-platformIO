"""
binary_serial_reader.py
- communication with baseplate: reads the baseplate's binary frames over serial and turns them into
  CubeNode trees; answers every frame with a feedback frame
- building-sequence protocol:
    PC -> baseplate : CMD_START -> baseplate begins detection
    baseplate -> PC : payload frame        
    PC -> baseplate : FEEDBACK FRAME from the compare result -> answered for every data frame of baseplate
    baseplate -> PC : RESP_DONE -> every cube confirmed the relayed feedback
                      or RESP_FB_FAILED -> relaying feedback failed
    PC -> baseplate : CMD_STOP -> baseplate relays an final empty frame (all LEDs off)

- iter_trees_from_binary_serial() = the entry point
    -> ws_server.py runs it in a worker thread and consumes the trees it yields
"""

"""connection to ws_server.py: iter_trees_from_binary_serial() -> ws_server.py runs it in a worker thread and consumes the yielded trees
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

# ----------------------------------------------------------
# Frame receive helpers
# ----------------------------------------------------------
"""
wait_for_valid_sync_cmd
- reads single bytes until a SYNC byte is found or timeout (1sec) with nothing arriving at all 
(idle = normal, since the sender only transmits on change)
- returns True if SYNC was found, False on idle timeout
    -> same structure as in hardware wait_for_valid_sync_cmd()
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
rx_frame
- reads the rest of a data frame (LEN | PAYLOAD | CHECKSUM) after a
  valid SYNC byte has already been consumed by the caller
- returns the payload bytes, or None if the frame was broken
  -> same structure as in the firmware rx-frame()
"""
def rx_frame(ser:serial.Serial) ->Optional[bytes]:

        # ser.read(1) blocks for at most `timeout` seconds (1sec), [0] converts the 1-byte bytes object to an int
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

# ----------------------------------------------------------
# Feedback reply
# ----------------------------------------------------------
"""
send_feedback_frame
- answers a payload frame: sends the complete feedback frame 
 and checks the baseplate's status reply
"""
def send_feedback_frame(ser: serial.Serial, frame: bytes, verbose: bool) -> None:

    ser.write(frame)

    status = ser.read(1)

    if not status:
        if verbose:
            print("No status byte from baseplate (timeout).")
    elif status[0] == RESP_DONE: # normal case: every cube confirmed the feedback
        pass    
    elif status[0] == RESP_FB_FAILED:
        print("Baseplate reports feedback failure (bad frame or a cube "
              "did not confirm).")
    elif verbose:
        print(f"Unexpected status byte: 0x{status[0]:02X}")

# ----------------------------------------------------------
# Main generator
# ----------------------------------------------------------
"""
iter_trees_from_binary_serial = main function
- tasks
    - opens the serial port
    - starts the baseplate
    -  continuously turns its binary frames into CubeNode trees
    - transmits a feedback frame to baseplate 
- GENERATOR: it yields one `CubeNode` tree (or `None` for "nothing built") per detection
frame and pauses here until the caller asks for the next one 
"""
def iter_trees_from_binary_serial(
    port: str, 
    baudrate: int = 115200,  # must match Serial.begin() in the firmware
    verbose: bool = True,   # False silences the idle/resync/heartbeat chatter

    # builds the feedback frame for a tree (None = nothing built)
    feedback_builder: Optional[Callable[[Optional[CubeNode]], bytes]] = None,


    # set from another thread to end the session; checked once per loop
    # iteration, so it takes effect within ~1 s even while idle
    stop_event: Optional[threading.Event] = None,
):


    with serial.Serial(port, baudrate, timeout=1) as ser:
        # drop any stale bytes still buffered from a previous run, so the
        # first frame we parse really belongs to this session
        ser.reset_input_buffer()

        # 1. send CMD Start: baseplate starts with its program
        ser.write(bytes([CMD_START]))
        print(f"Connected to {port} at {baudrate} baud, START sent.")

        # fallback for standalone use (no compare/target wiring supplied):
        # every frame gets answered with an empty feedback frame = all LEDs off
        if feedback_builder is None:
            feedback_builder = lambda tree: build_frame(b"") # build_frame from framing.py 

        last_payload: Optional[bytes] = None         # snapshot of last answered payload
        last_feedback_frame: Optional[bytes] = None  # its frame, resent on heartbeats

        # tracks consecutive idle timeouts with no frame at all - used to
        # detect a lost/forgotten START and resend it (see below)
        idle_timeouts_since_start = 0

        try:
            while True:
                # end_session message or browser disconnect requested a stop
                if stop_event is not None and stop_event.is_set():
                    break

                # 2. scan for the start of the next frame (timeout 1 sec)
                found_sync = wait_for_valid_sync_cmd(ser, verbose)

                if not found_sync:
                    # normal case: the construction hasn't changed, nothing was sent
                    if verbose:
                        print("Idle: no data received in the last second.")

                    # A lost START (session restarted too quickly, the
                    # firmware's STOP handling swallowed it) and the
                    # baseplate silently falling back to IDLE mid-session
                    # (e.g. a noise byte on the line misread as STOP) look
                    # identical from here: no more frames ever arrive.
                    # Resend START after a few seconds of silence in both
                    # cases - harmless if the baseplate is genuinely just
                    # idle between real detections (it only reacts to
                    # START anyway), but recovers a lost/dropped session
                    # without needing a manual restart.
                    idle_timeouts_since_start += 1
                    if idle_timeouts_since_start >= 5:
                        ser.write(bytes([CMD_START]))
                        idle_timeouts_since_start = 0
                        print("No frame for 3s - START (re)sent.")

                    continue            # keep scanning for the next SYNC

                idle_timeouts_since_start = 0   # real data arrived - reset the idle counter

                # 2. receive payload
                payload = rx_frame(ser)
                if payload is None:
                    continue   # broken frame: no reply, firmware's own timeout covers it

                # 3. heartbeat check: identical payload sent again just to prove the link is alive
                # the compare result would be unchanged too -> resend the cached feedback frame 
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

                # 4. send feedback frame created form feedback_output.py
                feedback_frame = feedback_builder(tree)
                send_feedback_frame(ser, feedback_frame, verbose)

                # update the snapshots only after a fully successful exchange
                last_payload = payload
                last_feedback_frame = feedback_frame

                yield tree   # hand the tree to the consumer, pause here

        finally:
            # 5. on generator close or error: send CMD Stop: the baseplate back to idle
            try:
                ser.write(bytes([CMD_STOP]))
            except serial.SerialException:
                pass
