"""Simulated tree source for testing the visualization without hardware.

Drop-in replacement for iter_trees_from_binary_serial: yields one
actual tree (CubeNode, or None for "nothing built") per story step,
waits, and loops forever.

The story walks through every status the frontend must render:
correct (green), wrong (red), attachable ghost, blocked (hidden),
unexpected (red).
"""
import time
from typing import Iterator, Optional

from cube_node import CubeNode, make_node

CUBE_A = 0x10
CUBE_B = 0x11
CUBE_C = 0x12
CUBE_D = 0x13


def _perfect_tower() -> CubeNode:
    return make_node(CUBE_A, 0, {
        0: make_node(CUBE_B, 0, {
            0: make_node(CUBE_C, 0),
        }),
    })


def _story() -> list[tuple[str, Optional[CubeNode]]]:
    return [
        ("nothing built - root slot attachable",
         None),

        ("cube A placed - correct, slot B attachable",
         make_node(CUBE_A)),

        ("cube B added with wrong orientation",
         make_node(CUBE_A, 0, {0: make_node(CUBE_B, 2)})),

        ("cube B orientation fixed",
         make_node(CUBE_A, 0, {0: make_node(CUBE_B, 0)})),

        ("cube B moved to wrong port - port error + ghost slot",
         make_node(CUBE_A, 0, {1: make_node(CUBE_B, 0)})),

        ("cube B back on right port",
         make_node(CUBE_A, 0, {0: make_node(CUBE_B, 0)})),

        ("cube C completes the tower",
         _perfect_tower()),

        ("extra cube D attached - unexpected",
         make_node(CUBE_A, 0, {
             0: make_node(CUBE_B, 0, {
                 0: make_node(CUBE_C, 0, {
                     0: make_node(CUBE_D, 0),
                 }),
             }),
         })),

        ("cube D removed - tower correct again",
         _perfect_tower()),
    ]


# Generator with the same shape as iter_trees_from_binary_serial:
# yields one tree per story step, then sleeps, and loops forever -
# ws_server.py can consume either source with the same for-loop.
def iter_trees_simulated(interval_s: float = 5.0) -> Iterator[Optional[CubeNode]]:
    while True:
        for label, tree in _story():
            print(f"[sim] {label}")
            yield tree
            time.sleep(interval_s)
