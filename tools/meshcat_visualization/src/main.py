import argparse
import time

from binary_serial_reader import iter_trees_from_binary_serial
from layout import compute_cube_transforms
from meshcat_scene import open_visualizer, draw_cube, draw_world_marker
from payload_parser import print_tree

# visualization - maybe another file
def redraw_tree(vis, root):
    vis["cubes"].delete()

    positioned_cubes = compute_cube_transforms(root)

    for path, node, transform in positioned_cubes:
        draw_cube(
            vis=vis,
            path=f"cubes/{path}",
            transform=transform,
            cube_id=node.cube_id
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", required=True, help="Serial port, for example COM4")
    parser.add_argument("--baud", type=int, default=9600)
    args = parser.parse_args()

    vis = open_visualizer()
    draw_world_marker(vis)

    #öffnet hauptfunction aus binary serial reader und printed tree und drawed tree in meshcat
    for root in iter_trees_from_binary_serial(args.port, args.baud):
        print("\nReceived valid tree:")
        print_tree(root)

        redraw_tree(vis, root)

        print("Meshcat scene updated.")

        #time.sleep(0.05)


if __name__ == "__main__":
    main()