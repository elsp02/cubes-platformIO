"""Target tree model: what the user is supposed to build.

Matching is done by cube TYPE (upper 3 bits of NODE_ID), never by the
full instance ID - two physical cubes of the same type are
interchangeable. The instance ID of whichever cube actually sits in a
slot is used later when building the feedback frame, because each cube
searches the frame for its complete NODE_ID.

NODE_ID layout: TTTIIIII (3 bits type, 5 bits instance).
NOTE: the current prototype cubes (0x10..0x12) are all type 0 under
this split, so type checks always pass until real type bits are
assigned.
"""
from dataclasses import dataclass, field

TYPE_SHIFT = 5
INSTANCE_MASK = 0x1F


def node_type(node_id: int) -> int:
    """Extract the 3-bit cube type from a NODE_ID."""
    return node_id >> TYPE_SHIFT


def node_instance(node_id: int) -> int:
    """Extract the 5-bit instance number from a NODE_ID."""
    return node_id & INSTANCE_MASK


@dataclass
class TargetNode:
    """One slot in the target construction.

    Parent and port are implicit in the tree structure, exactly like in
    the actual tree: children is a dict mapping child port -> TargetNode.
    """
    cube_type: int
    orientation: int
    children: dict[int, "TargetNode"] = field(default_factory=dict)


# ----------------------------------------------------------------
# Predefined target trees for testing (later: loaded per build step)
# ----------------------------------------------------------------

# Straight tower of three type-0 cubes, each child on port 0, all in
# orientation 0. Mirrors the current 3-cube prototype hardware.
TARGET_TOWER_3 = TargetNode(
    cube_type=0,
    orientation=0,
    children={
        0: TargetNode(
            cube_type=0,
            orientation=0,
            children={
                0: TargetNode(cube_type=0, orientation=0),
            },
        ),
    },
)
