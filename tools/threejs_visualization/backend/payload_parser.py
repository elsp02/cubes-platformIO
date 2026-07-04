""" payload parser for visualization """

from cube_node import CubeNode

MAX_CHILDREN = 5

"""
    Node parsing and deserialization

    Node format:
    NODE_ID | ORIENTATION | CHILD_MASK
"""

def parse_node(payload: bytes, index: int, port: int | None) -> tuple[CubeNode, int]:

    if index + 3 > len(payload):
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

    for child_port in range(MAX_CHILDREN):
        if child_mask & (1 << child_port):
            child_node, index = parse_node(
                payload=payload,
                index=index,
                port=child_port
            )
            node.children.append(child_node)

    return node, index


"""main fct for tree deserialization"""
def parse_tree(payload: bytes) -> CubeNode:
    root, index = parse_node(
        payload=payload,
        index=0,
        port=None
    )

    if index != len(payload):
        raise ValueError(
            f"Payload was not fully consumed. Parsed {index} of {len(payload)} bytes."
        )

    return root


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