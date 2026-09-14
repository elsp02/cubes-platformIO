# Firmware
This directory contains the embedded firmware for the baseplate and the active bricks. All devices use an ATtiny1616 and are built with PlatformIO, the Arduino framework, and megaTinyCore.

## Directory structure
```text
firmware/
├── include/                          # Public declarations and shared configuration
│   ├── config.h                      # Timing, protocol bytes, limits
│   ├── cube_hardware.h               # Brick child-port declarations
│   ├── cube_identity.h               # NODE_ID (cube type + instance) generation
│   ├── feedback.h / feedback_cube.h  # Feedback transmission and LED handling
│   ├── pc_communication.h            # Baseplate-to-PC communication helpers
│   ├── detection.h                   # functions for child detection
│   ├── serial_writing.h              # Serial logging and payload-change tracking
│   └── wire_bus.h                    # Single-wire byte and frame interface
└── src/      
    ├── state_machine/                # Current baseplate and cube implementation
    ├── firmware_test/                # Minimal UART handshake test
    └── lib/                          # Shared implementation used by all entry points
```

`platformio.ini` is located at the repository root (`src_dir = firmware/src`, `include_dir = firmware/include`) — build commands are run from the repository root, not from `firmware/`.

## Firmware targets
| Environment | Device | Entry point | Status |
|:--|:--|:--|:--|
| `uart_baseplate_state_machine` | Baseplate | `state_machine/baseplate_state_machine2.cpp` | firmware of the baseplate, implemented as an explicit state machine |
| `baseplate_state_machine_debug` | Baseplate | `state_machine/baseplate_state_machine_debug.cpp` | Standalone variant of the above: no PC connection, short debug codes printed |
| `uart_cube_state_machine` | Active brick | `state_machine/cube_state_machine.cpp` | firmware of a brick, implemented as an explicit state machine; pairs with `uart_baseplate_state_machine` |
| `uart_test` | Baseplate or test board | `firmware_test/main_uart_handshake.cpp` | Minimal bidirectional UART handshake, no topology or feedback logic |
| `Upload_UPDI` | Utility | — | Shared serial-UPDI upload configuration |
| `set_fuses` | Utility | — | Configures brown-out detection, EEPROM preservation, and the UPDI pin |


## Configure an active brick or the baseplate
### brick
Before flashing a brick with `uart_cube_state_machine`, set its build flags in
`platformio.ini`:

- `CUBE_TYPE_NORMAL`, `CUBE_TYPE_SMASHED`, or `CUBE_TYPE_PYRAMID`: physical
  brick type;
- `CUBE_INSTANCE`: instance number within that type.

Both are combined into the brick's `NODE_ID` at compile time — see [ID Explanation](../docs/communication-protocol.md#id-explanation) for the bit layout. Every physical brick must have a unique type-and-instance combination

### Baseplate
The baseplate is a single, fixed device, so no per-instance build flags are needed. `platformio.ini` already sets `-DCUBE_TYPE_BASEPLATE` for `uart_baseplate_state_machine`.


## Current development status
As of the latest development iteration, `uart_cube_state_machine` is
functional; `baseplate_state_machine_debug` is also working, but `uart_baseplate_state_machine` has an open, unresolved issue under
investigation: baseplate freezes when connecting with specific bricks -> after some connections and reconnections, the pc receives no frames from the baseplate anymore. environment worked in commit 
 `uart_baseplate`, `uart_cube` and `uart_test` remain buildable as earlier reference implementations.
