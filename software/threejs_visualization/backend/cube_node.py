"""CubeNode: the shared data type for one detected cube.

binary_serial_reader (via payload_parser) produces trees of CubeNode;
compare_core consumes them.
"""
from dataclasses import dataclass, field
from typing import Optional

TYPE_SHIFT = 5
INSTANCE_MASK = 0x1F

"""3-bit cube type from a NODE_ID to compare with target tree (no need of ID for target tree comparison)"""
def node_type(node_id: int) -> int:
    return node_id >> TYPE_SHIFT

"""5-bit instance number from a NODE_ID for FEEDBACK_FRAME to cubes to know which cube is adressed"""
def node_instance(node_id: int) -> int:
    return node_id & INSTANCE_MASK

@dataclass
class CubeNode:
    id: int                    # full NODE_ID byte (type + instance bits)
    orientation: int           # 0..3 = 0/90/180/270 degrees twist
    port: Optional[int]        # parent port this cube hangs on; None = root
    child_mask: int = 0        # bit N set = child present on port N
    children: list["CubeNode"] = field(default_factory=list)  # ascending port order
