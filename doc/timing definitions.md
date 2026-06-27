## Values
Timeout = maximum allowed waiting time before declaring failure.

**Term Explanation?**
| Term                             | Definition                                                                |
| --------------------------------------------- | ------------------------------------------------------------------------ |
| `BAUD_US`              | Time for one bit transfer                |
| `TURNAUROUND_US`       |                      |
| `CHILD_TIMEOUT_US`     | waiting time for ACK_BUSY after sending CMD_STATUS             |
| `FRAME_TIMEOUT_US`     | Waiting time for receiving DATA_FRAME (start of SYNC) after child finishes recursive polling -> (accumulating, therefore coding that if one child timeouts. then the whole process will be stopped and starts from beginning) |
| `INTER_FRAME_TIMEOUT_US` | waiting time for next byte in DATA_FRAME after SYNC when child already startet sending DATA_FRAME |
| `PARENT_TIMEOUT_US`      | waiting time for next CMD_STATUS from parent (also accumulating? -same as FRAME_TIMEOUT) -> maybe same principle as orientation detection better

CHILD_COUNT, CUBES_AMOUNT, CHILD_RETRIES

## Calculations
- **BYTE_US:** 10 bit times -> 10x BAUD_US
- **TURNAROUND_US:** 3x BAUD_US
- **CMD-ACK Process:** CMD + TURNAROUND + ACK -> 2x BYTE_US + TURNAROUND_US
    - **CHILD_TIMEOUT_US:** if process is valid, there should be no timeout needed -> maybe 2x TURNAROUND_US

- **Children polling process:** in poll_child function -> two possible outcomes:
    - FAILED_ATTEMPT_US - no child answers: 
        - for one child: MAX_RETRIES x (CMD_STATUS/BYTE_US + TURNAROUND + CHILD_TIMEOUT_US)
        - for all children: CHILD_PORT/COUNT x [MAX_RETRIES x (CMD_STATUS + TURNAROUND + CHILD_TIMEOUT_US)]
            => if child sends ACK_BUSY at the 3. retry round: [(MAX_RETRIES -1) x failed_attempt] + CMD-ACK process + BUILD_FRAME_TIME FRAME_TIME 

    - succeeded attempt - child answers with ACK and DATA FRAME [SYNC | LEN | PAYLOAD | CRC]:
        - DATA_FRAME_TIME: 3x BYTE_US + max CUBES_AMOUNT x(3x transmitted byte)
        - oder FRAME_TIME: (payload_len + 3) × BYTE_US


    - **FRAME_TIMEOUT_US:** child polls child polls child ... -> CUBES_AMOUNT x CHILD_COUNT x ([(MAX_RETRIES -1) x failed_attempt] + CMD-ACK process + DATA_FRAME_TIME + TURNAROUND) 

- **INTER_BYTE_US:** if process is valid, there should be no timeout needed -> maybe 2x TURNAROUND_US
- **PARENT_TIMEOUT_US:** same period of time as FRAME_TIMEOUT_US/ same principle as orientation detection 