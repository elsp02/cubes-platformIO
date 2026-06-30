import serial

from cube_node import CubeNode
from payload_parser import parse_tree


SYNC = 0xA5

#checksum validation
def checksum_xor(payload_len: int, payload: bytes) -> int:
    checksum = payload_len

    for byte in payload:
        checksum ^= byte

    return checksum

# read frame, like rx_frame  - vlt so umschreiben 
def read_exactly(ser: serial.Serial, number_of_bytes: int) -> bytes:
    data = ser.read(number_of_bytes)

    if len(data) != number_of_bytes:
        raise TimeoutError(
            f"Expected {number_of_bytes} bytes, received {len(data)} bytes."
        )

    return data

"""def rx_frame(ser:serial.Serial) ->bytes:

        payload_len = ser.read(1)[0]

        payload= ser.read(payload_len)
        if len(payload) != payload_len:
            raise TimeoutError(
            f"Expected {payload_len} bytes, received {len(payload)} bytes."
        )
        
        received_checksum = ser.read(1)[0]
            
        #check checksum
        calculated_checksum = checksum_xor(payload_len, payload) 

        if received_checksum != calculated_checksum:
                print("Checksum error. Frame ignored.")
                print(f"Received checksum:   0x{received_checksum:02X}")
                print(f"Calculated checksum: 0x{calculated_checksum:02X}")
                print(f"Payload: {payload.hex(' ')}")
                ser.reset_input_buffer() #?
                return/break -so würde es nach der function einfach weitergehen - irgendwie anders lösen
        return payload
        
"""
"""
    Reads single bytes until a SYNC byte is found, or the read times out
    with nothing arriving at all (idle -- normal, since the sender only
    transmits on change).

    Returns True if SYNC was found and consumed, False if idle timeout.

    Scanning byte-by-byte here (rather than assuming the very next byte
    IS sync) means we never have to manually track "how many stray bytes
    are left over from a broken frame" -- any leftover junk just gets
    consumed and skipped here until real alignment is found again.
"""
def wait_for_valid_sync_cmd(ser: serial.Serial, verbose: bool) -> bool:

    while True:
        b = ser.read(1)   #? is this function a generel function from a bib, like serial.print?

        if not b:
            return False   # idle timeout, nothing arrived at all

        if b[0] == SYNC:   # arrived byte is correct SYNC byte
            return True

        if verbose:         #?
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
    port: str,  #?
    baudrate: int = 9600,  
    verbose: bool = False,
):


    with serial.Serial(port, baudrate, timeout=1) as ser:
        ser.reset_input_buffer()   #?

        print(f"Connected to {port} at {baudrate} baud.") 

        while True:
            #like 
            found_sync = wait_for_valid_sync_cmd(ser, verbose)  #returns true (snyc found) or false (no data received)

            if not found_sync:
                if verbose:         #? what does this mean, its different than there was no new payload sent correct? 
                    print("Idle: no data received in the last second.")
                continue            # if no new payload received, begin again with wait_for_valid_sync_cmd 
            
            #read payload LEN PAYLOAD CRC - maybe more similar to my rx_frame umschreiben 
            try:  
                #rx_frame(ser)
                length_byte = read_exactly(ser, 1)
                payload_len = length_byte[0]

                payload = read_exactly(ser, payload_len)
                received_checksum = read_exactly(ser, 1)[0]

            except TimeoutError as error: #when is this called
                print(f"Serial timeout mid-frame (after valid SYNC): {error}")
                ser.reset_input_buffer()
                continue
            
            #check checksum -weg 
            calculated_checksum = checksum_xor(payload_len, payload) 

            if received_checksum != calculated_checksum:
                print("Checksum error. Frame ignored.")
                print(f"Received checksum:   0x{received_checksum:02X}")
                print(f"Calculated checksum: 0x{calculated_checksum:02X}")
                print(f"Payload: {payload.hex(' ')}")
                ser.reset_input_buffer() #?
                continue
            
            #parse payload to tree
            try:
                tree: CubeNode = parse_tree(payload)
                yield tree  #what is yield

            except ValueError as error: #when is this called?
                print(f"Parser error: {error}")
                print(f"Payload: {payload.hex(' ')}")
                ser.reset_input_buffer()