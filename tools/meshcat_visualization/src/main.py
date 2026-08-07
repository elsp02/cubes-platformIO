import argparse
import time

from binary_serial_reader import iter_trees_from_binary_serial
from layout import compute_cube_transforms
from meshcat_scene import open_visualizer, draw_cube, draw_world_marker
from payload_parser import print_tree

# visualization - redraws the whole tree every time a new valid payload arrives - maybe for final just redrawing hte cubes that changed 
def redraw_tree(vis, root):
    vis["cubes"].delete() #clear old visualization

    positioned_cubes = compute_cube_transforms(root) #compute posiiton and orientation of every cube

    for path, node, transform in positioned_cubes:
        draw_cube(
            vis=vis,
            path=f"cubes/{path}",  #name/location in Meshcat’s object hierarchy
            transform=transform,   #physical position of cube in 3D space
            cube_id=node.cube_id   # 
        )

# parser and args for starting program with python main.py --port COM4 --baud 9600 -> there are the infos for port and baudrate, so not hardcoded 
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", required=True, help="Serial port, for example COM4") #defines required argument for port 
    parser.add_argument("--baud", type=int, default=9600) #defines optional argument for baudrate with default value 9600
    args = parser.parse_args() #contains the actual values that were entered in the terminal.

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