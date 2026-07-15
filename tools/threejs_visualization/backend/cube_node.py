""" data class for Node and conversion to dictionary"""
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class CubeNode:
    id: int
    orientation: int
    port: Optional[int]
    child_mask: int = 0
    children: list["CubeNode"] = field(default_factory=list)

"""Builds a CubeNode with child_mask and child ports derived from a {port: child} dict.
Used by tests and the simulated source to define trees readably."""
def make_node(node_id: int, orientation: int = 0, children: dict[int, "CubeNode"] | None = None) -> CubeNode:
    children = children or {}
    child_mask = 0
    child_list = []

    for port in sorted(children):
        child_mask |= 1 << port
        children[port].port = port
        child_list.append(children[port])

    return CubeNode(
        id=node_id,
        orientation=orientation,
        port=None,
        child_mask=child_mask,
        children=child_list,
    )


"""Converts a CubeNode tree to a dictionary representation"""
def tree_to_dict(node: CubeNode) -> dict:
    return {
        "id": node.id,
        "orientation": node.orientation,
        "port": node.port,
        "child_mask": node.child_mask,
        "children": [tree_to_dict(child) for child in node.children]
    }
