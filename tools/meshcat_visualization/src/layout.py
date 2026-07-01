import numpy as np

from cube_node import CubeNode


CUBE_SIZE = 1.0
GAP = 0.04
PITCH = CUBE_SIZE + GAP


PORT_DIRECTIONS = {
    0: np.array([1.0, 0.0, 0.0]),    # parent +X port
    1: np.array([-1.0, 0.0, 0.0]),   # parent -X port
    2: np.array([0.0, 1.0, 0.0]),    # parent +Y port
    3: np.array([0.0, -1.0, 0.0]),   # parent -Y port
    4: np.array([0.0, 0.0, 1.0]),    # parent +Z port
}


def rotation_x(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [1.0, 0.0, 0.0],
        [0.0, c, -s],
        [0.0, s, c],
    ])


def rotation_y(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [c, 0.0, s],
        [0.0, 1.0, 0.0],
        [-s, 0.0, c],
    ])


def rotation_z(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [c, -s, 0.0],
        [s, c, 0.0],
        [0.0, 0.0, 1.0],
    ])


ATTACHMENT_ROTATIONS = {
    0: rotation_y(np.pi / 2.0),       # child +Z -> parent +X
    1: rotation_y(-np.pi / 2.0),      # child +Z -> parent -X
    2: rotation_x(-np.pi / 2.0),      # child +Z -> parent +Y
    3: rotation_x(np.pi / 2.0),       # child +Z -> parent -Y
    4: np.eye(3),                     # child +Z -> parent +Z
}


def orientation_to_twist(orientation: int) -> np.ndarray:
    orientation = orientation % 4
    return rotation_z(orientation * np.pi / 2.0)


def child_rotation_for_port(port: int, orientation: int) -> np.ndarray:
    if port not in ATTACHMENT_ROTATIONS:
        raise ValueError(f"Unknown port: {port}")

    attachment_rotation = ATTACHMENT_ROTATIONS[port]
    twist_rotation = orientation_to_twist(orientation)

    return attachment_rotation @ twist_rotation


def root_orientation_to_rotation(orientation: int) -> np.ndarray:
    return orientation_to_twist(orientation)


def make_transform(rotation: np.ndarray, translation: np.nFdarray) -> np.ndarray:
    transform = np.eye(4)
    transform[:3, :3] = rotation
    transform[:3, 3] = translation
    return transform

#calculate lokal child pose relative to direct parent
def local_transform_for_child(child: CubeNode) -> np.ndarray:
    """
    Computes T_parent_child.

    This transform is local:
    it describes the child relative to its direct parent.
    """

    if child.port is None:
        raise ValueError(f"Child cube {child.cube_id} has no port value.")

    if child.port not in PORT_DIRECTIONS:
        raise ValueError(f"Unknown port {child.port} on cube {child.cube_id}.")

    local_translation = PORT_DIRECTIONS[child.port] * PITCH  # = child center position relative to parent center

    local_rotation = child_rotation_for_port(
        port=child.port,
        orientation=child.orientation
    )

    return make_transform(
        rotation=local_rotation,
        translation=local_translation
    )


def compute_cube_transforms(
    root: CubeNode
) -> list[tuple[str, CubeNode, np.ndarray]]:
    """
    Returns local transforms for a Meshcat scene graph.

    Each transform is relative to the parent Meshcat path.
    Therefore, nested Meshcat paths are correct here.
    """

    result: list[tuple[str, CubeNode, np.ndarray]] = []

    root_transform = make_transform(
        rotation=root_orientation_to_rotation(root.orientation),
        translation=np.array([0.0, 0.0, 0.0])
    )

    def visit(node: CubeNode, path: str, local_transform: np.ndarray) -> None:
        result.append((path, node, local_transform))

        for child_index, child in enumerate(node.children):
            child_transform = local_transform_for_child(child)

            child_path = f"{path}/cube_{child.cube_id:02X}_{child_index}"

            visit(child, child_path, child_transform)

    visit(root, f"cube_{root.cube_id:02X}", root_transform)

    return result