"""
target_tree.py (same as cube_node.py just for target tree)
- defines TargetNode: the target construction selected by the user in the browser
- used by ws_server.py (parses the client's start_session message) and compare_core.py (comparison target)
"""

from dataclasses import dataclass, field

"""One Node in target tree construction
    Parent and port are implicit in the tree structure (like in the actual tree), children is a dict mapping child port -> TargetNode.
"""

# ----------------------------------------------------------
# TargetNode
# ----------------------------------------------------------

"""
TargetNode
- one node of the target construction: its type/ orientation plus its children
"""
@dataclass
class TargetNode:
    cube_type: int
    orientation: int
    children: dict[int, "TargetNode"] = field(default_factory=dict)

"""
target_node_from_json
- turns the JSON sent by the frontend into a TargetNode tree
    -> parses the frontend's target-tree JSON node into a TargetNode, recursively
"""
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
