>final 

# Communication Protocol
## Overview
The system uses two communication interfaces:

- a software-controlled single-wire half-duplex connection between the baseplate and the building bricks as well as between neighbouring bricks
- a hardware USART connection between the baseplate and the host computer

The messages for the construction detection and feedback data use a common binary frame format explained later in this document. Different commands and payload structures distinguish the individual communication processes.

For the overall system structure and data flow, see [System Architecture](docs/architecture.md).

## Communication Interfaces
| Communication Interface | Physical Implementation | Transmission Rate |
|:---|:---|:---|
| Learning application ↔ baseplate| Hardware USART through a USB-
to-TTL UART adapter | 115200 bit/s |
| Baseplate ↔ brick / brick ↔ brick| Software-controlled single-wire
half-duplex connection | approximately
9.6 kbit/s |

## Single-Wire Communication
Communication between two directly connected modules is implemented as a bidirectional single-wire half-duplex interface. The same data line is used alternately by the parent and child brick and only one participant may transmit at a time.  
The idle state of the line is logic HIGH. A transmitter either pulls the line LOW or releases it and uses the internal pull-up resistor.

Each byte uses a UART-like format:

![Single-wire byte transmission](..figures/Single-wire-byte.svg)

The implemented bit duration is `104 µs`, corresponding to approximately 9.`6 kbit/s`. A turnaround delay of `312 µs` is used when the transmission direction changes.

## Parent Child Communication
The communication within the physical construction follows a request–response procedure and is always initiated by the parent brick.  
Depending on the current process, the communication is used
either to retrieve the detected construction or to transmit feedback towards the connected bricks. The command and acknowledgement bytes used in the two processes are: 

| Message | Value | Direction | Meaning |
|---|---:|---|---|
| `CMD_STATUS` | `0xAA` | Parent → Child | Request detected subtree |
| `ACK_BUSY` | `0x55` | Child → Parent | Request received and being processed |
| `CMD_FEEDBACK` | `0xCC` | Parent → Child | Announce feedback frame |
| `ACK_FINISHED` | `0x66` | Child → Parent | Feedback successfully processed and forwarded |
| `ACK_FAILED` | `0x77` | Child → Parent | Feedback invalid or forwarding failed |

## Common Frame Format
Construction and feedback data forwarded from brick to brick are encapsulated in a variable-length binary frame:

| Field | Size | Description |
|:---|:---|:---|
| `SYNC`| 1 byte | Beginning of frame |
| `LEN` | 1 byte | Number of payload bytes | 
| `PAYLOAD` | 0-128 bytes | Message specific data |
| `CHECKSUM` | 1 byte | XOR checksum

The payload stored in the `PAYLOAD` field contains the information transmitted by the frame. Its structure depends on whether it contains the detected tree structure or the feedback message.

The checksum is calculated from the length field and all payload bytes.

## Construction Detection 
To retrieve the detected subtree of a connected child, the parent sends `CMD_STATUS`. The child responds with `ACK_BUSY` and subsequently queries its own downstream interfaces. After all subordinate information has been collected, the child returns a `DATA_FRAME` containing its own node information and the serialised representations of its child subtrees.

This process is applied recursively throughout the connected brick structure till the baseplate.

### Detection Payload
The payload (data) returned during this sequence represents the detected construction tree. Each brick contributes a three-byte node header, followed by the serialised representations of its subordinate bricks:

| Field | Size | Description |
|---|---:|---|
| `NODE_ID` | 1 byte | Brick type and individual instance |
| `ORIENTATION` | 1 byte | Relative orientation to the parent |
| `CHILD_MASK` | 1 byte | Occupied downstream interfaces |
| `CHILD_NODE_PAYLOAD` | variable | Serialised child subtrees |

Received child frames are not embedded as complete frames within the parent payload. Instead, only their payloads are appended in the predefined interface order to the parent’s own node information.

## Feedback Communication
The feedback communication is also initiated by the parent node, but with another command message: Feedback transmission is initiated using `CMD_FEEDBACK`. The child responds with `ACK_BUSY`, receives the `FEEDBACK_FRAME`, processes its own feedback state and forwards the frame to its detected children.

### Feedback Payload
The feedback payload (data) uses the common frame format but contains pairs of brick identifiers and LED states:

| Field | Size | Description |
|---|---:|---|
| `NODE_ID` | 1 byte | Identifier of the addressed brick |
| `LED_STATE` | 1 byte | Local feedback state |

If a brick's `NODE_ID` is not included in the feedback payload, its local LED output is switched off. An empty feedback payload is
therefore used at the end of a construction task to deactivate all local feedback simultaneously.

## Learning Application Baseplate Communication
Communication between the Python backend and the baseplate uses hardware USART through a USB-to-TTL UART adapter.

Serial configuration:
- 115200 bit/s
- 8 data bits
- no parity
- 1 stop bit

The learning application controls an interaction session using the following single-byte commands and responses: 

| Message | Value | Direction | Meaning |
|---|---:|---|---|
| `PC_CMD_START` | `0x53` (`S`) | Application → Baseplate | Start cyclic detection |
| `DATA_FRAME` | variable | Baseplate → Application | Current serialised construction |
| `FEEDBACK_FRAME` | variable | Application → Baseplate | Brick-specific feedback |
| `PC_RESP_FB_DONE` | `0x44` (`D`) | Baseplate → Application | Feedback successfully forwarded |
| `PC_RESP_FB_FAILED` | `0x4E` (`N`) | Baseplate → Application | Feedback invalid or forwarding failed |
| `PC_CMD_STOP` | `0x58` (`X`) | Application → Baseplate | Stop detection and clear feedback |

A session begins with `PC_CMD_START` of the learning application. The baseplate then detects the construction and transmits a `DATA_FRAME`.

After evaluating the construction, the application returns a `FEEDBACK_FRAME`. The baseplate forwards this frame to the connected bricks and reports the result using `PC_RESP_FB_DONE` or `PC_RESP_FB_FAILED`.

`PC_CMD_STOP` terminates cyclic detection and causes an empty feedback frame to be forwarded so that all brick LEDs are switched off.

## Validation and Error Handling??