# Sequence: Baseplate ↔ PC ↔ Visualization

Communication flow of the PC-controlled building sequence, from the baseplate
firmware over the serial link to the Python backend and on to the three.js
frontend. The detection and feedback exchanges on the wire bus between
baseplate and cubes are **abstracted** (single arrows) — this diagram focuses
on the serial protocol and the server/client side.

Source files:

- Firmware: `src/firmware_baseplate/uart_main_baseplate.cpp`
- Serial reader: `tools/threejs_visualization/backend/binary_serial_reader.py`
- WebSocket server: `tools/threejs_visualization/backend/ws_server.py`
- Frontend: `tools/threejs_visualization/frontend/src/ws_client.js`, `main.js`, `scene_glb.js`

## Pipeline overview

```mermaid
flowchart LR
    CU[Cubes] <-->|wire bus| BP[Baseplate firmware]
    BP <-->|"serial (USB), binary frames"| SR[Serial reader thread]
    SR -->|CubeNode tree| WS[WebSocket server + compare]
    WS -->|"tree_queue (newest only)"| H[WS handler]
    H -->|"JSON over ws://localhost:8765"| FE[Browser: three.js scene]
    WS -->|feedback frame via reader| BP
```

## Sequence diagram

```mermaid
sequenceDiagram
    autonumber
    participant CU as Cubes<br/>(wire bus)
    participant BP as Baseplate<br/>uart_main_baseplate.cpp
    participant SR as Serial reader<br/>binary_serial_reader.py<br/>(worker thread)
    participant WS as WebSocket server<br/>ws_server.py<br/>(asyncio, main thread)
    participant FE as Browser client<br/>ws_client.js + scene_glb.js

    Note over WS: start: tree_worker thread + websockets.serve()
    FE->>WS: WebSocket connect ws://localhost:8765
    SR->>BP: PC_CMD_START ('S') — serial, 115200 baud
    Note over BP: detection_running = true

    loop detection cycle (150 ms pacing)
        BP->>CU: detection sequence (abstracted)
        CU-->>BP: child payloads
        Note over BP: build payload<br/>NODE_ID · ORIENTATION · CHILD_MASK · child payloads

        opt payload changed OR heartbeat (50 cycles unchanged)
            BP->>SR: payload frame — SYNC · LEN · PAYLOAD · CHECKSUM
            Note over SR: wait_for_valid_sync_cmd() + rx_frame()<br/>(checksum validated)

            alt heartbeat (payload identical to last one)
                Note over SR: reuse cached feedback frame,<br/>no new tree is yielded
            else new payload
                SR->>SR: parse_tree(payload) → CubeNode tree
                SR->>WS: feedback_builder(tree)
                Note over WS: compare(tree, TARGET) → led_states
                WS-->>SR: feedback frame bytes
            end

            SR->>BP: feedback frame — SYNC · LEN · [NODE_ID, LED_STATE]… · CHECKSUM
            BP->>CU: relay CMD_FEEDBACK + frame (abstracted, with retries)
            CU-->>BP: ACK_FINISHED per present cube

            alt every present cube confirmed
                BP->>SR: PC_RESP_DONE ('D')
            else bad frame from PC or a cube failed
                BP->>SR: PC_RESP_FB_FAILED ('N')
            end

            opt new payload (not a heartbeat)
                SR->>WS: yield tree (generator → tree_worker loop)
                WS->>WS: evaluate_tree(): compare(tree, TARGET)<br/>+ build_evaluated_tree() → dict
                WS->>WS: tree_queue.put() — maxsize 1,<br/>unread stale tree is dropped
                WS->>FE: JSON { "type": "evaluated_tree", "tree": … }
                FE->>FE: redrawTree(tree) in the three.js scene
            end
        end
    end

    Note over SR,BP: shutdown (Ctrl+C / generator close)
    SR->>BP: PC_CMD_STOP ('X')
    BP->>CU: empty feedback frame = all LEDs off (abstracted)
    Note over BP: detection_running = false → idle,<br/>waits for the next START
    FE--xWS: connection closed → clearTree() (scene emptied)
```

## Error handling on the serial link

| Situation | Detected by | Reaction |
|---|---|---|
| Broken payload frame from baseplate (timeout mid-frame, checksum mismatch) | Serial reader (`rx_frame`) | Input buffer flushed, byte-by-byte re-sync on the next SYNC; **no reply sent** — the firmware's `PC_REPLY_TIMEOUT_MS` covers it and the cycle continues |
| Payload does not parse into a valid tree | Serial reader (`parse_tree` raises `ValueError`) | Frame dropped, buffer flushed, no feedback frame — firmware timeout covers it |
| Broken feedback frame from PC (wrong SYNC, bad length/checksum, byte gap) | Firmware (`read_pc_reply` → `PC_REPLY_BAD`) | Stray bytes drained, `PC_RESP_FB_FAILED` sent, next cycle continues |
| No reply from PC at all | Firmware (`PC_REPLY_TIMEOUT`) | Nothing sent, next detection cycle continues |
| A cube does not confirm the relayed feedback after all retries | Firmware (`relay_feedback_to_children`) | `PC_RESP_FB_FAILED` sent to the PC (reported, not fatal) |
| Status byte from baseplate missing or `FB_FAILED` | Serial reader (`send_feedback_frame`) | Logged only, never fatal — the stream continues |

Two details worth remembering when reading the diagram:

- **Every valid payload frame must be answered** (heartbeats included) — the
  firmware blocks for up to `PC_REPLY_TIMEOUT_MS` waiting for the feedback
  frame, so a silent PC would stall each frame for that timeout.
- `compare()` runs **twice per tree** (once for the feedback frame in the
  reader thread, once in `evaluate_tree` for the frontend dict); trees are
  small, so recomputing is simpler than sharing the result across the
  thread boundary.
