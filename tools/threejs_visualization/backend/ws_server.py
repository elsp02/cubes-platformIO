# this server compares the actual tree against the target tree and sends
# the evaluated tree in json to the websocket client (just for one client, no broadcasting)
# documentation on https://websockets.readthedocs.io/en/stable/intro/tutorial1.html
import asyncio
import json
from queue import Empty, Queue
from threading import Thread

import websockets

from compare_core import compare
from feedback_output import build_evaluated_tree
from target_tree import TARGET_TOWER_3

#--------------------------------
# Configuration
#--------------------------------
USE_SIMULATION = True    # True: scripted build story, False: real baseplate on SERIAL_PORT
SIM_INTERVAL_S = 5.0     # seconds per simulated story step

SERIAL_PORT = 'COM4'  # Change this to your serial port
BAUDRATE = 115200  # must match Serial.begin() in the baseplate firmware
WEBSOCKET_HOST = 'localhost'
WEBSOCKET_PORT = 8765

TARGET = TARGET_TOWER_3  # the construction the user is supposed to build

#stores only the newest evaluated tree
tree_queue: Queue[dict] = Queue(maxsize=1)


# selects where actual trees come from; both sources yield CubeNode trees
# (imports happen here so simulation mode works without pyserial installed)
def tree_source():
    if USE_SIMULATION:
        from simulated_source import iter_trees_simulated
        print(f"Starting simulated source ({SIM_INTERVAL_S}s per step).")
        return iter_trees_simulated(SIM_INTERVAL_S)

    from binary_serial_reader import iter_trees_from_binary_serial
    print(f"Starting serial reader on {SERIAL_PORT} at {BAUDRATE} baud.")
    return iter_trees_from_binary_serial(SERIAL_PORT, BAUDRATE)


# orchestrator: actual tree (CubeNode or None) -> evaluated tree dict
# (parse happens in the source; feedback frame to the baseplate comes later)
def evaluate_tree(actual) -> dict:
    result = compare(actual, TARGET)
    return build_evaluated_tree(result)


#worker thread -> runs the tree source in the background, compares every
#received tree against the target and puts the evaluated tree into the queue
def tree_worker() -> None:
    try:
        for actual in tree_source():
            evaluated = evaluate_tree(actual)

            # keep only the newest tree: drop the unread old one first
            if tree_queue.full():
                try:
                    tree_queue.get_nowait()
                except Empty:
                    pass
            tree_queue.put_nowait(evaluated)

    except Exception as error:
        print(f"Tree worker stopped because of an error: {error}")


#websocket handler -> Sends the newest evaluated tree to the connected browser
async def handler(websocket) -> None:
    print("Browser connected.")

    try:
        while True:
            try:
                tree = tree_queue.get_nowait()

            except Empty:
                await asyncio.sleep(0.02)
                continue

            payload = {
                "type": "evaluated_tree",
                "tree": tree,
            }
            # send evaluated tree to websocket client
            await websocket.send(json.dumps(payload))

    #connection closed correctly
    except websockets.ConnectionClosedOK:
        print("Connection closed")

    #connection closed with error
    except websockets.ConnectionClosedError:
        print("Connection closed with error")


async def main()-> None:
    async with websockets.serve(handler, WEBSOCKET_HOST, WEBSOCKET_PORT):
        print(
            f"WebSocket server started on "
            f"ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}"
        )
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    worker_thread = Thread(
        target=tree_worker,
        daemon=True,
    )

    worker_thread.start()

    asyncio.run(main())
