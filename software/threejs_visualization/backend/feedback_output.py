"""
feedback_output.py
- derives the two outputs from one compare() result in compare_core.py:
  1. LED FEEDBACK FRAME: feedback payload with NODE_IDs and LED_STATEs
  2. evaluated tree: the full merged view including attachable/blocked ghost slots.

- both are built from the same CompareEntry tree, just walked differently: 
    -> led_states() only looks at physically present cubes,
    -> build_evaluated_tree() keeps the whole tree, including empty ATTACHABLE/BLOCKED ghost slots
"""
from compare_core import CompareEntry, NodeStatus, iter_entries
from framing import build_frame


# ----------------------------------------------------------
# LED feedback frame for the baseplate
# ----------------------------------------------------------

# LED states as understood by the brick firmware (config.h)
LED_GREEN = 0x01 #correct brick
LED_RED   = 0x02 # wrong/unexpected brick

"""
led_states
- (node_id, led_state) for every physically present cube
    -> ghost slots (ATTACHABLE/BLOCKED) are not physically and are therefore skipped
"""
def led_states(result: CompareEntry) -> list[tuple[int, int]]:
    entries = []

    for entry in iter_entries(result):
        if entry.node_id is None:
            continue  # empty target slot, no cube to light

        if entry.status is NodeStatus.CORRECT:
            entries.append((entry.node_id, LED_GREEN))
        else:  # WRONG or UNEXPECTED
            entries.append((entry.node_id, LED_RED))

    return entries

"""
build_feedback_frame
- packs the (node_id, led_state) pairs into the feedback payload and wraps it into a full frame ready to send to the baseplate
"""
def build_feedback_frame(entries: list[tuple[int, int]]) -> bytes:
    payload = bytearray()

    for node_id, led_state in entries:
        payload.append(node_id)
        payload.append(led_state)

    return build_frame(bytes(payload)) # defined in framing.py


# ----------------------------------------------------------
# Evaluated tree for browser
# ----------------------------------------------------------
"""
build_evaluated_tree
- recursively turns the whole CompareEntry tree into a plain dict for the frontend
"""
def build_evaluated_tree(result: CompareEntry) -> dict:
    return {
        "status": result.status.value,
        "error_mask": result.error_mask,
        "node_id": result.node_id,
        "orientation": result.orientation,
        "port": result.port, #real port
        "expected_type": result.expected_type,
        "expected_orientation": result.expected_orientation,
        "expected_port": result.expected_port, # None for _invalid_path/_unexpected entries - no known correct position at all
        "children": [build_evaluated_tree(child) for child in result.children],
    }
