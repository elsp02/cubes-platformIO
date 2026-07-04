import numpy as np

from cube_node import CubeNode

#cube geometry  
CUBE_SIZE = 1.0
GAP = 0.04
PITCH = CUBE_SIZE + GAP

#maps every parent port index to direction in parent cubes local system - need to be changed
PORT_DIRECTIONS = {
    0: np.array([1.0, 0.0, 0.0]),    # parent +X port
    1: np.array([-1.0, 0.0, 0.0]),   # parent -X port
    2: np.array([0.0, 1.0, 0.0]),    # parent +Y port
    3: np.array([0.0, -1.0, 0.0]),   # parent -Y port
    4: np.array([0.0, 0.0, 1.0]),    # parent +Z port
}

#rotation matrix around X axis - for -Z Face of child cube points to parents +/-Y port
def rotation_x(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [1.0, 0.0, 0.0],
        [0.0, c, -s],
        [0.0, s, c],
    ])

#rotation matrix around Y axis - for -Z Face of child cube points to parents +/-X port
def rotation_y(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [c, 0.0, s],
        [0.0, 1.0, 0.0],
        [-s, 0.0, c],
    ])

#rotation matrix around Z axis - for cubes detected orientation value
def rotation_z(angle_rad: float) -> np.ndarray:
    c = np.cos(angle_rad)
    s = np.sin(angle_rad)

    return np.array([
        [c, -s, 0.0],
        [s, c, 0.0],
        [0.0, 0.0, 1.0],
    ])

#Rotation that aligns the child cube's -Z side with the selected parent port.
ATTACHMENT_ROTATIONS = {
    0: rotation_y(np.pi / 2.0),       # child +Z -> parent +X
    1: rotation_y(-np.pi / 2.0),      # child +Z -> parent -X
    2: rotation_x(-np.pi / 2.0),      # child +Z -> parent +Y
    3: rotation_x(np.pi / 2.0),       # child +Z -> parent -Y
    4: np.eye(3),                     # child +Z -> parent +Z
}#example: if child is connected to port 0 -> rotate +90 around Y axis

#converts detected orientation value into rotation matrix
# values: 0=0°, 1=90°, 2=180°, 3=270° around Z axis
def orientation_to_twist(orientation: int) -> np.ndarray:
    orientation = orientation % 4 #orientation always between 0-3 -> do i need this?
    return rotation_z(orientation * np.pi / 2.0)

# calculates complete rotation of child cube including fac attachement rotation and twist rotation 
def child_rotation_for_port(port: int, orientation: int) -> np.ndarray:
    if port not in ATTACHMENT_ROTATIONS:
        raise ValueError(f"Unknown port: {port}") #valid port - not needed because already checked in local_transform_for_child

    attachment_rotation = ATTACHMENT_ROTATIONS[port] #childs -Z face rotation to parent port
    twist_rotation = orientation_to_twist(orientation) #childs orientation

    return attachment_rotation @ twist_rotation #combine both relations; @ = matrix multiplication

#for root cube which has no parent - no face attachement rotation, just orientation/twist rotation
def root_orientation_to_rotation(orientation: int) -> np.ndarray:
    return orientation_to_twist(orientation)

# needed for set_transform() - 4x4 transformation matrix 
def make_transform(rotation: np.ndarray, translation: np.nFdarray) -> np.ndarray:
    transform = np.eye(4)
    transform[:3, :3] = rotation
    transform[:3, 3] = translation
    return transform

#calculates full local pose of child cube relative to its parent cubes coordinates
def local_transform_for_child(child: CubeNode) -> np.ndarray:

    if child.port is None: #child has port?
        raise ValueError(f"Child cube {child.cube_id} has no port value.")

    if child.port not in PORT_DIRECTIONS: #does port exist
        raise ValueError(f"Unknown port {child.port} on cube {child.cube_id}.")

    #translation
    local_translation = PORT_DIRECTIONS[child.port] * PITCH  # = child center position relative to parent center

    #rotation 
    local_rotation = child_rotation_for_port(
        port=child.port,
        orientation=child.orientation
    )

    return make_transform(
        rotation=local_rotation,
        translation=local_translation
    )

# takes root or parsed cube tree and returns a list of all cubes with: Path, Node, transform for redraw_tree() function 
def compute_cube_transforms(
    root: CubeNode
    #list with every cube that should be drawn
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

    #recursive tree traversal for every cube 
    def visit(node: CubeNode, path: str, local_transform: np.ndarray) -> None:
        result.append((path, node, local_transform))

        for child_index, child in enumerate(node.children):
            child_transform = local_transform_for_child(child)

            child_path = f"{path}/cube_{child.cube_id:02X}_{child_index}"

            #recursive call 
            visit(child, child_path, child_transform)
    #starts with the visit function begging of the root 
    visit(root, f"cube_{root.cube_id:02X}", root_transform)

    return result