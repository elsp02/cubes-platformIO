"""
from user selected target tree model - received from client/browser
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
