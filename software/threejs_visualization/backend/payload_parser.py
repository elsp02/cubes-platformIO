"""Payload parser: turns detection payload bytes into a CubeNode tree.

Position in the pipeline:

    binary_serial_reader.py (or a test fixture)
        --payload bytes--> THIS FILE --> CubeNode tree --> compare_core.py

The firmware serializes the detected construction depth-first: each
cube writes its own 3-byte header, then the full payload of every
child in ascending port order. parse_tree() reverses exactly that.
"""

from cube_node import CubeNode

MAX_CHILDREN = 5   # ports 0..4, must match the firmware's child_mask width

"""
    Node parsing and deserialization

    Node format (3-byte header, then the children's bytes):
    NODE_ID | ORIENTATION | CHILD_MASK

    CHILD_MASK: bit N set = a child cube is attached on port N, and its
    bytes follow directly after this header (depth-first, ports in
    ascending order). The mask is what makes the flat byte stream
    unambiguous - no length fields per node are needed.
"""

# Parses one node (and, recursively, its whole subtree) starting at
# byte position `index`. Returns (node, index_after_subtree) - passing
# the index along like this is what lets the recursion walk the flat
# byte stream without ever copying or slicing it.
# `port` is the parent port this node hangs on (None for the root).
def parse_node(payload: bytes, index: int, port: int | None) -> tuple[CubeNode, int]:

    if index + 3 > len(payload):
        # fewer than 3 bytes left where a node header must start:
        # payload is truncated (e.g. child_mask promised a child that
        # never arrived in the bytes)
        raise ValueError("Payload too short while parsing node header.")

    id = payload[index]
    orientation = payload[index + 1]
    child_mask = payload[index + 2]
    index += 3

    #same as alloc node
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

    return node, index


"""main fct for tree deserialization: whole payload -> root CubeNode"""
def parse_tree(payload: bytes) -> CubeNode:
    root, index = parse_node(
        payload=payload,
        index=0,
        port=None
    )

    if index != len(payload):
        # leftover bytes after the root's subtree ended = the payload
        # does not describe exactly one tree -> corrupt, better to
        # reject it than to silently show a wrong construction
        raise ValueError(
            f"Payload was not fully consumed. Parsed {index} of {len(payload)} bytes."
        )

    return root


"""inverse of parse_tree: node -> detection payload bytes.

Children must be stored in ascending port order and match child_mask,
which is exactly what parse_tree produces. Used to build readable test
fixtures and to verify parse/serialize round-trips.
"""
def serialize_tree(node: CubeNode) -> bytes:
    out = bytearray((node.id, node.orientation, node.child_mask))

    for child in node.children:
        out += serialize_tree(child)

    return bytes(out)


"""debug helper: prints the tree structure with indentation per level"""
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
