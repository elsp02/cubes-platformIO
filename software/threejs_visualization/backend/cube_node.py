"""
cube_node.py
- defines CubeNode: the shared data type for one detected cube 
- built by payload_parser.py (parses the serialized payload from the baseplate into a tree)
- consumed by compare_core.py (??)
"""

from dataclasses import dataclass, field
from typing import Optional

# ----------------------------------------------------------
# NODE_ID bit layout
# - NODE_ID packs brick type (bits 7..5) and per-type instance (bits 4..0)
# ----------------------------------------------------------

TYPE_SHIFT = 5
INSTANCE_MASK = 0x1F


"""
node_type
- 3-bit brick type from a NODE_ID, used to compare against the target tree
- no need of the brick ID for target tree comparison
"""
def node_type(node_id: int) -> int:
    return node_id >> TYPE_SHIFT

"""
node_instance
- 5-bit instance number from a NODE_ID
- used to address one cube in the feedback frame
"""
def node_instance(node_id: int) -> int:
    return node_id & INSTANCE_MASK


# ----------------------------------------------------------
# CubeNode
# ----------------------------------------------------------

"""
CubeNode
- one detected cube: its identity/orientation plus its children
"""
@dataclass
class CubeNode:
    id: int                    # full NODE_ID byte (type + instance bits)
    orientation: int           # 0..3 = 0/90/180/270 degrees twist
    port: Optional[int]        # parent port this cube hangs on; None = root
    child_mask: int = 0        # bit N set = child present on port N
    children: list["CubeNode"] = field(default_factory=list)  # ascending port order
