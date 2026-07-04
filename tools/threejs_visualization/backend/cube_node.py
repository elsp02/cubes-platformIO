""" data class for Node and conversion to dictionary"""
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class CubeNode:
    cube_id: int
    orientation: int
    port: Optional[int]
    child_mask: int = 0
    children: list["CubeNode"] = field(default_factory=list)

"""Converts a CubeNode tree to a dictionary representation"""
def tree_to_dict(node: CubeNode) -> dict:
    return {
        "cube_id": node.cube_id,
        "orientation": node.orientation,
        "port": node.port,
        "child_mask": node.child_mask,
        "children": [tree_to_dict(child) for child in node.children]
    }
