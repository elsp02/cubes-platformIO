from typing import Optional

import serial

from cube_node import CubeNode
from payload_parser import parse_tree


SYNC = 0xA5

#checksum validation
def calc_checksum(payload_len: int, payload: bytes) -> int:
    checksum = payload_len

    for byte in payload:
        checksum ^= byte

    return checksum

""" for reading DATA_FRAME after valid SYNC appeared"""
def rx_frame(ser:serial.Serial) ->Optional[bytes]:

        payload_len = ser.read(1)[0]


        payload= ser.read(payload_len)
        if len(payload) != payload_len:
            print(f"Timeout reading payload: expected {payload_len}, got {len(payload)}.")
            ser.reset_input_buffer()
            return None
        
        received_checksum = ser.read(1)[0]
            
        #check checksum
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

    Returns True if SYNC was found +correct, false if idle timeout.
"""
def wait_for_valid_sync_cmd(ser: serial.Serial, verbose: bool) -> bool:

    while True:
        b = ser.read(1)   # reads exactly one byte

        if not b:
            return False   # idle timeout, nothing arrived at all

        if b[0] == SYNC:   # arrived byte is correct SYNC byte
            return True

        if verbose:         
            print(f"Skipping unexpected byte while resyncing: 0x{b[0]:02X}")


""" = hauptfunction in der wait_for_valid_sync_cmd drin ist 
    Continuously reads binary frames from the serial port.

    Frame:
    SYNC | LEN | PAYLOAD | CHECKSUM

    The sender only transmits a frame when its payload has actually
    changed, so long stretches with no bytes at all are the normal,
    expected case -- not an error.

    Any failure partway through a frame (timeout, checksum mismatch,
    or parse error) flushes the input buffer and falls back to
    byte-by-byte SYNC scanning, so a broken/partial frame can never
    leave stray bytes behind to misalign the next read.
"""
def iter_trees_from_binary_serial(
    port: str,  # port defined as string, e.g. "COM3"
    baudrate: int = 9600,  
    verbose: bool = True,
):


    with serial.Serial(port, baudrate, timeout=1) as ser:
        ser.reset_input_buffer()   #?

        print(f"Connected to {port} at {baudrate} baud.") 

        while True:
            #like 
            found_sync = wait_for_valid_sync_cmd(ser, verbose)  #returns true (snyc found) or false (no data received)

            if not found_sync:
                if verbose:         #? debug variable
                    print("Idle: no data received in the last second.")
                continue            # if no new payload received, begin again with wait_for_valid_sync_cmd 
            
            payload = rx_frame(ser)
            if payload is None:
                continue
            
            #parse payload to tree
            try:
                tree: CubeNode = parse_tree(payload)
                yield tree  #what is yield

            except ValueError as error: #when is this called?
                print(f"Parser error: {error}")
                print(f"Payload: {payload.hex(' ')}")
                ser.reset_input_buffer()