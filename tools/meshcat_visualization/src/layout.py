import numpy as np

from cube_node import CubeNode


CUBE_SIZE = 1.0
GAP = 0.04
PITCH = CUBE_SIZE + GAP


# Adapt this mapping to your real cube geometry.
#
# Example:
# port 0 = +X
# port 1 = -X
# port 2 = +Y
# port 3 = -Y
# port 4 = +Z
# upstream_side = -Z
PORT_DIRECTIONS = {
    0: np.array([1.0, 0.0, 0.0]),
    1: np.array([-1.0, 0.0, 0.0]),
    2: np.array([0.0, 1.0, 0.0]),
    3: np.array([0.0, -1.0, 0.0]),
    4: np.array([0.0, 0.0, 1.0]),
}


def rotation_z(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [c, -s, 0.0],
        [s,  c, 0.0],
        [0.0, 0.0, 1.0],
    ])


def orientation_to_rotation(orientation: int) -> np.ndarray:
    """
    Temporary model:
    orientation 0 = 0°
    orientation 1 = 90°
    orientation 2 = 180°
    orientation 3 = 270°

    Later replace this with your exact mechanical orientation mapping.
    """

    orientation = orientation % 4

    if orientation == 0:
        return rotation_z(0.0)
    if orientation == 1:
        return rotation_z(np.pi / 2)
    if orientation == 2:
        return rotation_z(np.pi)
    if orientation == 3:
        return rotation_z(3 * np.pi / 2)

    return np.eye(3)


def make_transform(rotation: np.ndarray, translation: np.ndarray) -> np.ndarray:
    transform = np.eye(4)
    transform[:3, :3] = rotation
    transform[:3, 3] = translation
    return transform


def compute_cube_transforms(
    root: CubeNode
) -> list[tuple[str, CubeNode, np.ndarray]]:
    """
    Returns a list of:
    path, node, transform
    """

    root_rotation = orientation_to_rotation(root.orientation)
    root_transform = make_transform(
        rotation=root_rotation,
        translation=np.array([0.0, 0.0, 0.0])
    )

    result: list[tuple[str, CubeNode, np.ndarray]] = []

    def visit(node: CubeNode, parent_transform: np.ndarray, path: str):
        result.append((path, node, parent_transform))

        for child_index, child in enumerate(node.children):
            if child.port is None:
                raise ValueError(f"Child cube {child.cube_id} has no port value.")

            if child.port not in PORT_DIRECTIONS:
                raise ValueError(f"Unknown port {child.port} on cube {child.cube_id}.")

            local_translation = PORT_DIRECTIONS[child.port] * PITCH
            local_rotation = orientation_to_rotation(child.orientation)

            child_local_transform = make_transform(
                rotation=local_rotation,
                translation=local_translation
            )

            child_world_transform = parent_transform @ child_local_transform

            child_path = f"{path}/cube_{child.cube_id:02X}_{child_index}"

            visit(child, child_world_transform, child_path)

    visit(root, root_transform, f"cube_{root.cube_id:02X}")

    return result