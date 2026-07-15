"""CubeNode: the shared data type for one detected cube.

Every tree source (binary_serial_reader, simulated_source, test
fixtures) produces trees of CubeNode; compare_core consumes them.
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

"""Builds a CubeNode with child_mask and child ports derived from a {port: child} dict.
Used by tests and the simulated source to define trees readably -
you only write {port: node} and mask/port fields are filled in
consistently (the same invariants parse_tree guarantees)."""
def make_node(node_id: int, orientation: int = 0, children: dict[int, "CubeNode"] | None = None) -> CubeNode:
    children = children or {}
    child_mask = 0
    child_list = []

    # sorted() => children end up in ascending port order, exactly like
    # the firmware serializes them
    for port in sorted(children):
        child_mask |= 1 << port           # set the mask bit for this port
        children[port].port = port        # tell the child where it hangs
        child_list.append(children[port])

    return CubeNode(
        id=node_id,
        orientation=orientation,
        port=None,     # caller (or a surrounding make_node) sets this
        child_mask=child_mask,
        children=child_list,
    )


"""Converts a CubeNode tree to a dictionary representation (JSON-ready) - for client """
def tree_to_dict(node: CubeNode) -> dict:
    return {
        "id": node.id,
        "orientation": node.orientation,
        "port": node.port,
        "child_mask": node.child_mask,
        "children": [tree_to_dict(child) for child in node.children]
    }
