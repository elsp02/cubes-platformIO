import meshcat
import meshcat.geometry as g
import numpy as np

from layout import CUBE_SIZE


# Map each local face direction to a color.
# Adjust to taste -- these are just placeholders.
FACE_COLORS = {
    "+x": 0x00FF00,  # green
    "-x": 0xFFFF00,  # yellow
    "+y": 0x0000FF,  # blue
    "-y": 0xFF8000,  # orange
    "+z": 0xFF0000,  # red
    "-z": 0xFFFFFF,  # white
}


def open_visualizer() -> meshcat.Visualizer:
    vis = meshcat.Visualizer().open()
    vis.delete()
    return vis


def _face_transform(face: str, size: float) -> np.ndarray:
    """
    Returns the LOCAL transform (relative to the cube's own center)
    that places a thin plane on the given face, facing outward.
    """
    half = size / 2.0
    transform = np.eye(4)

    if face == "+x":
        transform[:3, :3] = np.array([
            [0, 0, 1],
            [0, 1, 0],
            [-1, 0, 0],
        ])
        transform[:3, 3] = [half, 0, 0]
    elif face == "-x":
        transform[:3, :3] = np.array([
            [0, 0, -1],
            [0, 1, 0],
            [1, 0, 0],
        ])
        transform[:3, 3] = [-half, 0, 0]
    elif face == "+y":
        transform[:3, :3] = np.array([
            [1, 0, 0],
            [0, 0, 1],
            [0, -1, 0],
        ])
        transform[:3, 3] = [0, half, 0]
    elif face == "-y":
        transform[:3, :3] = np.array([
            [1, 0, 0],
            [0, 0, -1],
            [0, 1, 0],
        ])
        transform[:3, 3] = [0, -half, 0]
    elif face == "+z":
        transform[:3, 3] = [0, 0, half]
    elif face == "-z":
        transform[:3, :3] = np.array([
            [1, 0, 0],
            [0, -1, 0],
            [0, 0, -1],
        ])
        transform[:3, 3] = [0, 0, -half]
    else:
        raise ValueError(f"Unknown face: {face}")

    return transform


def draw_cube(
    vis: meshcat.Visualizer,
    path: str,
    transform: np.ndarray,
    cube_id: int
) -> None:
    """
    Draws a cube as six independently-colored thin planes (faces)
    instead of a single solid-color Box, so each face can show a
    different color (e.g. to indicate port/orientation visually).
    """

    # Slightly thinner than the cube itself so faces don't z-fight
    # with each other at the edges.
    face_size = CUBE_SIZE * 0.98
    plane_thickness = 0.01

    vis[path].set_transform(transform)

    for face, color in FACE_COLORS.items():
        plane = g.Box([face_size, face_size, plane_thickness])
        material = g.MeshLambertMaterial(color=color, transparent=False)

        face_path = f"{path}/{face}"
        vis[face_path].set_object(plane, material)
        vis[face_path].set_transform(_face_transform(face, CUBE_SIZE))


def draw_world_marker(vis: meshcat.Visualizer) -> None:
    """
    Small origin cube for orientation.
    """

    marker = g.Box([0.12, 0.12, 0.12])
    material = g.MeshLambertMaterial(color=0xFF0000)

    transform = np.eye(4)
    transform[:3, 3] = [0.0, 0.0, 0.0]

    vis["world/origin"].set_object(marker, material)
    vis["world/origin"].set_transform(transform)