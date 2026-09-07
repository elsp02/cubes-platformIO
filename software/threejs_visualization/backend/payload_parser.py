"""
payload_parser.py
- turns detected payload into a CubeNode tree, and serializes it back again
- receives transmitted payload from binary_serial_reader.py
- hands the parsed CubeNode tree over to compare_core.py
"""

from cube_node import CubeNode

MAX_CHILDREN = 5   # ports 0..4, must match the firmware's child_mask width

# ----------------------------------------------------------
# Parsing
# ----------------------------------------------------------

"""
parse_node
- parses one node (and, recursively, its whole subtree) starting at
  byte position `index`
- returns (node, index_after_subtree)
- `port` is the parent port this node hangs on (None for the root)
"""
def parse_node(payload: bytes, index: int, port: int | None) -> tuple[CubeNode, int]:

    if index + 3 > len(payload):
        raise ValueError("Payload too short while parsing node header.")

    id = payload[index]
    orientation = payload[index + 1]
    child_mask = payload[index + 2]
    index += 3

     # children are filled in below, one per set bit in child_mask
    node = CubeNode(
        id=id,
        orientation=orientation,
        port=port,
        child_mask= child_mask,
        children=[]
    )

    # walk the mask bit by bit; the children's bytes appear in exactly
    # this order (ascending ports), so index moves forward through them
    for child_port in range(MAX_CHILDREN):
        if child_mask & (1 << child_port):
            child_node, index = parse_node(
                payload=payload,
                index=index,
                port=child_port
            )
            node.children.append(child_node)

    return node, index # index = cursor, points to the first byte after this node's whole subtree (where the next sibling starts)


"""
parse_tree
- main fct for tree deserialization: whole payload 
    -> deserializes a whole payload into its root CubeNode
"""
def parse_tree(payload: bytes) -> CubeNode:
    root, index = parse_node(
        payload=payload,
        index=0,
        port=None
    )

    if index != len(payload):
        # rejects a payload that doesn't describe exactly one tree, instead of silently showing a wrong construction
        raise ValueError(
            f"Payload was not fully consumed. Parsed {index} of {len(payload)} bytes."
        )

    return root

# ----------------------------------------------------------
# Serialize
# ----------------------------------------------------------
"""
serialize_tree
- inverse of parse_tree: CubeNode -> detection payload bytes
- used to build readable test fixtures and to verify parse/serialize round-trips
"""

def serialize_tree(node: CubeNode) -> bytes:
    out = bytearray((node.id, node.orientation, node.child_mask))

    for child in node.children:
        out += serialize_tree(child)

    return bytes(out)

# ----------------------------------------------------------
# Debug
# ----------------------------------------------------------
"""
print_tree
- prints the tree structure with indentation per level
"""
def print_tree(node, depth: int = 0):
    indent = "  " * depth

    if node.port is None:
        port_text = "root"
    else:
        port_text = f"port {node.port}"

    print(
        f"{indent}- cube 0x{node.id:02X}, "   #hex zahl mit mind 2 stellen
        f"child_mask= 0x{node.child_mask:02X}, "
        f"orientation={node.orientation}, "
        f"{port_text}"
    )

    for child in node.children:
        print_tree(child, depth + 1)
