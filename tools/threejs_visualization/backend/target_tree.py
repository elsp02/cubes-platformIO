"""
from user selected target tree model - received from client/browser

Port numbers are TYPE-RELATIVE: the firmware's child_mask bit N is the
Nth entry of that cube type's children[] wiring array (0-based), so the
same port number can mean a different face on a different cube type.
Target trees must use these per-type port numbers; the geometry lives
in frontend/src/layout.js (PORT_GEOMETRY) - keep the two in sync:

  type 0 = cube    (IDs 0x00-0x1F): 0=+X, 1=-X, 2=+Y, 3=-Y, 4=+Z
  type 1 = smashed (IDs 0x20-0x3F): 0=+Z (only usable face)
  type 2 = wedge   (IDs 0x40-0x5F): 0=+X (square face), 1=45deg slope
"""
from dataclasses import dataclass, field

"""One Node in target tree construction
    Parent and port are implicit in the tree structure (like in the actual tree), children is a dict mapping child port -> TargetNode.
"""
@dataclass
class TargetNode:
    cube_type: int
    orientation: int
    children: dict[int, "TargetNode"] = field(default_factory=dict)

#new for client sending target tree to server
"""Parses the frontend target-tree JSON node into a TargetNode."""
def target_node_from_json(data: dict) -> TargetNode:
    if not isinstance(data, dict):
        raise ValueError(f"tree node must be an object, got {type(data).__name__}")

    children: dict[int, TargetNode] = {}
    for child in data.get("children", []):
        if "port" not in child:
            raise ValueError("child node is missing its 'port' field")
        port = int(child["port"])
        if port in children:
            raise ValueError(f"duplicate child port {port}")
        children[port] = target_node_from_json(child)

    return TargetNode(
        cube_type=int(data.get("cube_type", 0)),
        orientation=int(data.get("orientation", 0)),
        children=children,
    )
