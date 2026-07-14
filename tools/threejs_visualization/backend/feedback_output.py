"""Derives the two outputs from one compare result:

1. LED feedback frame (binary, PC -> baseplate -> cubes):
   SYNC | LEN | [NODE_ID, LED_STATE] x n | CHECKSUM
   Contains only physically present cubes - a missing cube has no LED.

2. Evaluated tree (dict, PC -> websocket -> three.js frontend):
   the full merged view including attachable/blocked ghost slots.

led_states is the persistent v1 mapping (green while correct, red
while wrong). The transition version ("green only for newly attached
cubes") will replace exactly this function later:
derive_led_states(prev_result, curr_result).
"""
from compare_core import CompareEntry, NodeStatus, iter_entries
from framing import build_frame

# LED states as understood by the cube firmware (config.h)
LED_GREEN = 0x01
LED_RED   = 0x02


def led_states(result: CompareEntry) -> list[tuple[int, int]]:
    """(node_id, led_state) for every physically present cube, DFS order."""
    entries = []

    for entry in iter_entries(result):
        if entry.node_id is None:
            continue  # empty target slot, no cube to light

        if entry.status is NodeStatus.CORRECT:
            entries.append((entry.node_id, LED_GREEN))
        else:  # WRONG or UNEXPECTED
            entries.append((entry.node_id, LED_RED))

    return entries


def build_feedback_frame(entries: list[tuple[int, int]]) -> bytes:
    """Complete feedback frame ready to send to the baseplate."""
    payload = bytearray()

    for node_id, led_state in entries:
        payload.append(node_id)
        payload.append(led_state)

    return build_frame(bytes(payload))


def build_evaluated_tree(result: CompareEntry) -> dict:
    """JSON-ready dict of the merged actual/target view for the frontend."""
    return {
        "status": result.status.value,
        "error_mask": result.error_mask,
        "node_id": result.node_id,
        "orientation": result.orientation,
        "port": result.port,
        "expected_type": result.expected_type,
        "expected_orientation": result.expected_orientation,
        "children": [build_evaluated_tree(child) for child in result.children],
    }
