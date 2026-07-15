# PC-side comparison core (target tree vs. actual tree + feedback outputs)

## Context

The cube system's feedback logic (doc/feedback.txt, steps 3–5) runs on the PC for now (later ESP32-S2, in C). Goal of this stage: implement and validate the **pure comparison logic** with predefined trees only — **no serial/ATtiny communication, no websocket wiring yet**. Decisions already made in conversation:

- Pure functions only (no side effects) so logic is unit-testable and portable to C later.
- Match target slots by cube **type** (upper 3 bits of NODE_ID), not instance ID; the feedback frame carries the actual instance's full NODE_ID.
- Missing cubes are **not errors** (step-by-step building): distinguish *attachable* (parent placed & correct) from *blocked*.
- Extra cube = error bit 4 (`1 << 4`), LED red.
- LED mapping v1 = **persistent**: green while correct, red while wrong. Transition-green ("newest cube only") comes later as a drop-in `derive_led_states(prev, curr)` layer — so `compare()` must not bake LED colors into its result.
- Two outputs from one compare result: binary **feedback frame** (present cubes only, `SYNC LEN [NODE_ID, LED]×n CRC`) and JSON-ready **evaluated tree** (incl. attachable/blocked ghost slots).

All new code in `tools/threejs_visualization/backend/` (the living copy; `meshcat_visualization` duplicate untouched for now).

## Existing code to reuse

- `payload_parser.py` — `parse_tree(bytes) -> CubeNode` (already pure; recursion gives each node its `port`, parent is implicit in structure). `MAX_CHILDREN = 5`.
- `cube_node.py` — `CubeNode` dataclass + `tree_to_dict`.
- `binary_serial_reader.py:12` — `calc_checksum` (XOR over LEN+payload). Problem: that module imports `pyserial`, so tests can't import it cleanly → move checksum into a new pure `framing.py` and re-import from there.

## Files to create / modify

### 1. `target_tree.py` (new)
- `TYPE_SHIFT = 5`, helpers `node_type(id)`, `node_instance(id)`.
- `@dataclass TargetNode: cube_type, orientation, children: dict[int, TargetNode]` (parent/port implicit in structure).
- One hardcoded example target `TARGET_TOWER_3` (3 type-0 cubes chained on port 0) matching the current prototype hardware.
- **Note/flag:** current cube IDs 0x10–0x12 are all type 0 under the 3/5 split — type checks always pass with today's hardware; real type bits come later.

### 2. `payload_parser.py` (modify: add one function)
- `serialize_tree(CubeNode) -> bytes` — exact inverse of `parse_tree` (NODE_ID, ORIENTATION, CHILD_MASK, then children in ascending-port order). Purpose: readable test fixtures + round-trip validation.

### 3. `compare_core.py` (new — the heart)
- Node status enum: `CORRECT`, `WRONG`, `ATTACHABLE`, `BLOCKED`, `UNEXPECTED`.
- Error mask bits (matching doc/feedback.txt): type=1<<0, parent=1<<1, port=1<<2, orientation=1<<3, unexpected=1<<4.
- `@dataclass CompareEntry: node_id (None for missing slots), status, error_mask, port, path info as needed for the evaluated tree`.
- `compare(actual: CubeNode | None, target: TargetNode) -> CompareResult` — parallel recursive walk:
  - present + all checks pass → CORRECT; recurse children normally.
  - present + mismatch (type/orientation) → WRONG with mask; **structural rule:** all present descendants → WRONG (parent-invalid bit), all missing target descendants → BLOCKED.
  - target slot empty in actual: parent CORRECT → ATTACHABLE, else BLOCKED.
  - actual cube where target has no slot → UNEXPECTED (bit 4 only), its subtree also UNEXPECTED.
  - parent/port errors fall out of the positional walk (a cube on the wrong port of a correct parent = port error; wrong-parent situations are what the structural rule propagates).

### 4. `framing.py` (new, pure — no pyserial import)
- `SYNC = 0xA5`, `calc_checksum(len, payload)` (moved verbatim from `binary_serial_reader.py`), `build_frame(payload) -> bytes`.
- `binary_serial_reader.py` gets a one-line change to import checksum/SYNC from here (no behavior change).

### 5. `feedback_output.py` (new)
- `led_states(result) -> list[(node_id, led_state)]` — persistent v1: CORRECT→0x01 green, WRONG/UNEXPECTED→0x02 red; missing slots excluded (no physical cube). Kept as its own function = the seam where transition-green slots in later.
- `build_feedback_frame(entries) -> bytes` using `framing.build_frame`.
- `build_evaluated_tree(result) -> dict` — actual tree annotated with `status` + `error_mask`, plus ghost entries for ATTACHABLE/BLOCKED slots (frontend renders attachable as "place next").

### 6. `test_compare.py` (new)
Plain pytest-style functions (also runnable via `python test_compare.py` with a tiny `__main__` runner, so no hard pytest dependency). Scenarios, each built with `serialize_tree` → `parse_tree` → `compare` → outputs:
1. round-trip serialize/parse
2. perfect match (all CORRECT, all green, frame content check incl. CRC)
3. wrong orientation / wrong port / wrong type (one each, mask checked)
4. missing cube with correct parent → ATTACHABLE (not in frame, in evaluated tree)
5. missing cube under missing/wrong parent → BLOCKED
6. extra cube → UNEXPECTED, bit 4, red
7. wrong parent invalidates descendants (structural rule)
8. empty actual tree → root ATTACHABLE, empty feedback frame

## Verification

- Run `python -m pytest tools/threejs_visualization/backend/test_compare.py -v` (or `python test_compare.py`) — all scenarios green.
- Round-trip test proves fixture helper and parser agree.
- Perfect-match test asserts exact frame bytes incl. checksum → locks the frame format against the firmware side (`wire_bus.cpp` uses the same XOR scheme).

## Explicitly out of scope (later stages)

- Transition-green `derive_led_states(prev, curr)`.
- Serial + websocket wiring (`ws_server.py`), sending frames to the baseplate.
- Multiple construction steps / JSON target-tree format.
- De-duplicating `meshcat_visualization` copies.

---
## Data models (no dependencies, everything builds on these)
### cube_node.py — the actual tree (what is physically built)

- CubeNode — dataclass for one detected cube: id, orientation, port, child_mask, children.
- tree_to_dict(node) — converts a CubeNode tree to a plain dict for JSON (used by the websocket path).

### target_tree.py — the expected tree (what should be built)

- TargetNode — dataclass for one slot: cube_type, orientation, children as {port: TargetNode}.
- node_type(id) / node_instance(id) — split a NODE_ID into its 3-bit type and 5-bit instance.
- TARGET_TOWER_3 — the hardcoded example target (3-cube tower).

## Byte-level helpers (depend on nothing / models only)
### framing.py — the shared frame format SYNC | LEN | PAYLOAD | CRC

- calc_checksum(len, payload) — XOR checksum, identical to wire_bus.cpp on the firmware side.
- build_frame(payload) — wraps any payload into a complete frame.
### payload_parser.py — payload bytes ↔ CubeNode tree

- parse_tree(payload) — deserializes a detection payload into a CubeNode tree (your feedback.txt step 3); derives each node's port from the recursion, parent stays implicit.
- parse_node(...) — internal recursive worker for one node + its subtree.
- serialize_tree(node) — exact inverse of parse_tree; exists for test fixtures and round-trip checks.
- print_tree(node) — debug printout, used nowhere programmatically.

## The logic core (the heart — steps 4–5 of feedback.txt)
### compare_core.py — uses CubeNode + TargetNode, nothing else

- compare(actual, target) — the one entry point: walks both trees in parallel and returns a CompareEntry result tree where every slot has a status (correct / wrong / attachable / blocked / unexpected) and an error mask.
- iter_entries(result) — flat depth-first iteration over a result tree (how consumers read it).
- Internals, one per situation: _compare_slot (cube present → check type/orientation, apply structural rule), _missing_slot (empty target slot → attachable or blocked), _misplaced (right cube, wrong port → ERR_PORT), _invalid_path (descendants of a misplaced cube), _unexpected (cube with no target slot).
### feedback_output.py — turns one compare result into the two outputs

- led_states(result) — result tree → [(node_id, led)] for present cubes only; persistent mapping (correct=green, else red). This is the function the transition-green version will replace later.
- build_feedback_frame(entries) — LED entries → complete binary frame for the baseplate (via framing.build_frame).
- build_evaluated_tree(result) — result tree → JSON-ready dict for three.js, including the attachable/blocked ghost slots.

## I/O layer (side effects live here, and only here)
### binary_serial_reader.py — serial port → trees (imports framing + parse_tree)

- wait_for_valid_sync_cmd(ser) — scans byte-by-byte for SYNC (resync after garbage).
- rx_frame(ser) — reads LEN + payload + CRC after a SYNC, validates the checksum.
- iter_trees_from_binary_serial(port) — the generator gluing it together: yields a parsed CubeNode tree whenever a new (non-heartbeat) payload arrives.

### ws_server.py — trees → browser

- serial_worker() — background thread: consumes iter_trees_from_binary_serial, converts via tree_to_dict, puts the newest tree in a 1-slot queue.
- handler(websocket) — sends whatever is in the queue to the connected browser as JSON.
- main() — starts the websocket server.

### test_compare.py — exercises everything except the I/O layer

- make_node(...) / perfect_tower() — fixture builders (compute child_mask for you).
- run_compare(actual) — runs the full pipeline serialize → parse → compare per test.
- test_* — the 11 scenarios; statuses/find/ghosts are small lookup helpers.
### How it flows together

serial port ──▶ binary_serial_reader ──▶ payload_parser.parse_tree ──▶ CubeNode tree
                                                                          │
                                              target_tree.TargetNode ──▶ compare_core.compare
                                                                          │
                                                              CompareEntry result tree
                                                                    ┌─────┴─────┐
                                              feedback_output.led_states   build_evaluated_tree
                                                        │                        │
                                              build_feedback_frame          JSON dict
                                              (framing.build_frame)              │
                                                        │                        ▼
                                                        ▼               ws_server ──▶ browser
                                          (later: serial back to baseplate)
The important property: everything in the middle rows (payload_parser, target_tree, compare_core, feedback_output, framing) is pure — bytes and dataclasses in, bytes and dicts out — which is exactly the part that later moves to the ESP32. Only the top and bottom rows (binary_serial_reader, ws_server) touch hardware or network, and they're not yet connected to the compare pipeline — ws_server currently sends the raw detected tree (tree_to_dict); switching it to send build_evaluated_tree output is part of the later wiring step.

