# Backend
This directory contains the Python backend of the learning application. It
bridges the baseplate's serial link and the three.js frontend's WebSocket connection: 
- deserializing the serialized tree provided by the baseplate
- reconstructing the detected construction
- comparing it against the selected target
- deriving feedback for both the browser and the physical bricks

## Directory structure
```text
backend/
├── ws_server.py             # entry point: WebSocket server, session lifecycle
├── binary_serial_reader.py  # communication with the baseplate
├── framing.py               # binary frame format constants and framing for the feedback payload which is sent to the pc
├── payload_parser.py         # turns detected payload into a parsed CubeNode tree and serializes it back again
├── cube_node.py              # defines CubeNode: one detected brick received from baseplate
├── target_tree.py            # defines TargetNode: target construction recieved from browser
├── compare_core.py           # actual tree vs. target tree comparison
├── feedback_output.py        # derives compared result into LED feedback frame for baseplate + evaluated tree JSON for browser
└── requirements_backend.txt  # pyserial, websockets
```

## Data flow
How a detection frame turns into feedback, inside the backend:
```text
binary_serial_reader --> payload_parser --> CubeNode tree
                                                  |
                                                  v
                    target_tree (from browser) -> compare_core
                                                  |
                                                  v
                                           feedback_output
                                              |        |
                                 LED feedback frame   evaluated tree (dict)
```


(see [software/README.md](../../README.md#system-overview) for how this fits into the browser <-> baseplate round trip)

## Configuration
`ws_server.py` currently hard-codes its connection settings at the top of the file:

| Constant | Meaning |
|:--|:--|
| `SERIAL_PORT` | COM port the baseplate is connected on (e.g. `COM4`) |
| `BAUDRATE` | must match `Serial.begin()` in the baseplate firmware (115200) |
| `WEBSOCKET_HOST` / `WEBSOCKET_PORT` | address the frontend connects to |

## Running
```bash
pip install -r requirements_backend.txt
python ws_server.py
```
The baseplate must be connected and flashed with `uart_baseplate_state_machine`
(see [firmware/README.md](../../../firmware/README.md)) before a session is
started from the frontend.


## compare
`compare_core.compare()` walks the detected `CubeNode` tree together with the
target `TargetNode` tree and produces a `CompareEntry` tree. `feedback_output
.build_evaluated_tree()` turns that into the plain JSON sent to the browser as
`{"type": "evaluated_tree", "tree": ...}`.

Every node in that tree carries:

| Field | Meaning |
|:--|:--|
| `status` | `correct` / `wrong` / `attachable` / `blocked` / `unexpected` |
| `error_mask` | bitmask of what's wrong (type/orientation/port/parent/unexpected) |
| `node_id`, `orientation` | the physically detected cube at this slot, or `null` if nothing is built there |
| `expected_type`, `expected_orientation`, `expected_port` | what the target wants at this slot, or `null` if there is no valid target correspondence (e.g. an unexpected cube) |
| `children` | nested evaluated entries, one per target slot plus any extra/misplaced physical cubes |

The frontend (`tree_builder.js` + `scene_glb.js`) interprets `status` as follows:
- `correct` -> cube rendered with a green pulsing outline
- `wrong` / `unexpected` -> cube rendered with a red pulsing outline
- `attachable` -> no physical cube yet; rendered as a semi-transparent "ghost"
  using the expected type/orientation, showing where to build next
- `blocked` -> not rendered at all (its parent isn't correct yet, so nothing
  here can be built either)

## Session lifecycle
One session = one browser tab = one open COM port. `ws_server.py` enforces
this with a single `current_session` slot guarded by an `asyncio.Lock`:

1. Browser connects and sends `{"type": "start_session", "tree": ..., "level": ...}`.
   Any previous session is stopped and its thread joined (so the COM port is
   released) before the new one opens the serial port and sends `CMD_START`.
2. Every detected tree is compared against the target; the evaluated tree is
   pushed to the browser as `{"type": "evaluated_tree", "tree": ...}` and the
   corresponding LED feedback frame is sent back to the baseplate as the
   reply to its detection frame.
3. Browser sends `{"type": "end_session"}`, or disconnects (tab closed,
   reload, crash) — either way the session's serial worker is signalled to
   stop, `CMD_STOP` is sent, and the COM port is closed before a new session
   may start.

   `binary_serial_reader.py iter_trees_from_binary_serial()` is a generator: it
yields one `CubeNode` tree (or `None` for "nothing built") per detection
frame and is driven by `ws_server.py`'s per-session worker thread.

Every yielded tree is immediately compared against the session's target twice —
once inside the reader to build the LED feedback frame sent back over
serial, once in the worker to build the evaluated tree sent to the browser
— since a compare pass over a handful of nodes is cheaper than sharing the
result across the thread boundary.

