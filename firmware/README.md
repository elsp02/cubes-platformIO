# Firmware

This directory contains the embedded firmware for the baseplate and the active
bricks of the tangible learning system. All devices use an ATtiny1616 and are
built with PlatformIO, the Arduino framework, and megaTinyCore.


the firmware folder consists of
- **include**: Public declarations and shared configurations
- **src**: shared implementations and baseplate and active brick program (entry points)
- **platformio.ini**: board settings, build targets and source selection

-------
The baseplate detects the connected brick structure and acts as the bridge to
the learning application. Each brick communicates with its parent, polls its
own children, adds its data to the detected structure, and relays visual
feedback to the bricks below it.

```text
Learning application / Python backend
                  │
                  │ UART, 115200 baud
                  ▼
              Baseplate
                  │
                  │ single-wire parent-child protocol
                  ▼
            Active brick tree
                  │
                  └── topology data and LED feedback
```

## Directory structure

```text
firmware/
├── platformio.ini              # Board settings, build targets and source selection
├── include/                    # Public declarations and shared configuration
│   ├── config.h                # Timing, protocol bytes, limits and brick identities
│   ├── cube_hardware.h         # Brick child-port declarations
│   ├── feedback.h              # Feedback transmission and LED handling
│   ├── pc_communication.h      # Baseplate-to-PC communication helpers
│   ├── poll_child.h            # Child polling interface
│   ├── serial_writing.h        # Serial logging and payload-change tracking
│   ├── tree_parser.h           # Experimental tree parser; currently unused
│   └── wire_bus.h              # Single-wire byte and frame interface
└── src/
    ├── firmware_baseplate/      # Baseplate program entry points
    ├── firmware_cube/           # Active-brick program entry points
    ├── firmware_test/           # Small hardware and communication tests
    ├── lib/                     # Shared implementations
    └── state_machine/           # Alternative state-machine prototypes
```

Only the files selected by `build_src_filter` in `platformio.ini` are compiled
for a given target. The files in `src/state_machine/` are not selected by any
current build target.

## Firmware targets

| Environment | Device | Entry point | Purpose |
|:--|:--|:--|:--|
| `baseplate` | Baseplate | `src/firmware_baseplate/main_baseplate_feedback2.cpp` | Detects the brick topology, sends it to the PC, and runs the prototype feedback sequence. This is the default environment. |
| `cube` | Active brick | `src/firmware_cube/main_cube_feedback2.cpp` | Polls child bricks, reports its subtree to its parent, and applies or relays LED feedback. |
| `uart_baseplate` | Baseplate | `src/firmware_baseplate/uart_main_baseplate.cpp` | PC-controlled workflow: waits for start/stop commands, sends detected topology frames, receives feedback frames, and relays them to the bricks. |
| `uart_cube` | Active brick | `src/firmware_cube/uart_main_cube.cpp` | Brick firmware paired with `uart_baseplate`; applies dynamic feedback received from the backend. |
| `uart_test` | Baseplate or test board | `src/firmware_test/main_uart_handshake.cpp` | Minimal bidirectional UART handshake without topology or feedback logic. |
| `Upload_UPDI` | Utility | — | Shared serial-UPDI upload configuration. |
| `set_fuses` | Utility | — | Configures brown-out detection, EEPROM preservation, and the UPDI pin. |

## Requirements

- ATtiny1616-based baseplate or active-brick hardware
- PlatformIO Core or the PlatformIO extension for Visual Studio Code
- A serial-UPDI programmer for flashing the microcontroller
- A 5 V TTL serial adapter for communication with the PC

The shared configuration in `platformio.ini` selects the ATtiny1616, a 20 MHz
internal oscillator, the Arduino framework, and a serial monitor speed of
115200 baud.

## Build and upload

Run PlatformIO from this directory:

```sh
cd firmware
```

Build a specific environment:

```sh
pio run -e uart_baseplate
pio run -e uart_cube
```

Upload it through the serial-UPDI programmer:

```sh
pio run -e uart_baseplate -t upload
pio run -e uart_cube -t upload
```

From the repository root, the equivalent form is:

```sh
pio run -d firmware -e uart_baseplate
```

Use the following command only when the fuse configuration needs to be written:

```sh
pio run -e set_fuses -t fuses
```

## Configure an active brick

Firmware-specific compile-time settings are defined in `platformio.ini` and
shared constants are defined in `include/config.h`.

Before flashing an active brick, configure:

- `CHILD_COUNT`: number of possible downstream child connections;
- `CUBE_TYPE_NORMAL`, `CUBE_TYPE_SMASHED`, or `CUBE_TYPE_PYRAMID`: physical
  brick type;
- `CUBE_INSTANCE`: instance number within that type.

The firmware combines the type and instance into a one-byte node identifier:

```text
bits 7..5: brick type
bits 4..0: instance number
```

Every physical brick must have a unique type-and-instance combination. Flash
each brick separately after changing its build flags.

## Communication overview

The brick network uses an open-drain-like, single-wire connection. Data is sent
as UART-like bytes and grouped into frames:

```text
SYNC | LENGTH | PAYLOAD | CHECKSUM
```

During topology detection, the baseplate polls its child. Each active brick
recursively polls its own children and returns an aggregated subtree payload.
The orientation of a connection is encoded in the topology data.

In the PC-controlled workflow, the baseplate sends the topology frame to the
Python backend. The backend compares the detected construction with the target
construction and returns feedback items as pairs:

```text
NODE_ID | LED_STATE
```

The baseplate distributes this frame through the brick tree. A matching brick
sets its green or red LED and forwards the same feedback to its children.

For byte values, frame semantics, acknowledgements, and timeouts, see the
[communication protocol](../docs/communication-protocol.md) and
[timing definitions](../docs/timing-definitions.md). Hardware connections and
pin assignments are described in the [hardware documentation](../docs/hardware.md).

## UART handshake test

The `uart_test` environment verifies communication between the PC and USART0 of
the ATtiny1616 without involving the single-wire bus. Its default pins are PB2
for TX and PB3 for RX.

Build and upload the test:

```sh
pio run -e uart_test -t upload
```

At 115200 baud, the expected exchange is:

```text
PC -> ATtiny: S    ATtiny -> PC: A
PC -> ATtiny: F    ATtiny -> PC: D
```

It can be exercised manually with a serial monitor or with
[`tools/uart_test/handshake_test.py`](../tools/uart_test/handshake_test.py).

## Current development status

The firmware is a research prototype and still contains alternative and legacy
implementations for comparison. The `uart_test` environment currently builds
successfully. The main `baseplate`, `cube`, `uart_baseplate`, and `uart_cube`
environments are undergoing a transition from direct `NODE_ID` build flags to
the type-and-instance identity scheme and require that configuration to be
aligned before they build successfully.
