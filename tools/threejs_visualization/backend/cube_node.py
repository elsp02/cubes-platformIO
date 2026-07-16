"""CubeNode: the shared data type for one detected cube.

binary_serial_reader (via payload_parser) produces trees of CubeNode;
compare_core consumes them.
"""
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class CubeNode:
    id: int                    # full NODE_ID byte (type + instance bits)
    orientation: int           # 0..3 = 0/90/180/270 degrees twist
    port: Optional[int]        # parent port this cube hangs on; None = root
    child_mask: int = 0        # bit N set = child present on port N
    children: list["CubeNode"] = field(default_factory=list)  # ascending port order
