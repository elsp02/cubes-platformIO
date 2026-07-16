# WebSocket server: the glue between baseplate, comparison and frontend.
#
# Position in the pipeline:
#
#   real baseplate (binary_serial_reader)
#       --CubeNode tree--> compare against TARGET --evaluated dict-->
#           --JSON over websocket--> three.js frontend
#   and back: compare result --feedback frame--> baseplate --> cube LEDs
#
# Architecture: the serial reader blocks on the serial port, so it runs
# in its own worker THREAD. The websocket part runs in the asyncio
# event loop of the main thread. The two sides only meet at tree_queue.
#
# (just for one client, no broadcasting)
# documentation on https://websockets.readthedocs.io/en/stable/intro/tutorial1.html
import asyncio
import json
from queue import Empty, Queue
from threading import Thread

import websockets

from binary_serial_reader import iter_trees_from_binary_serial
from compare_core import compare
from feedback_output import build_evaluated_tree, build_feedback_frame, led_states
from target_tree import TARGET_TOWER_3

#--------------------------------
# Configuration
#--------------------------------
SERIAL_PORT = 'COM4'  # Change this to your serial port
BAUDRATE = 115200  # must match Serial.begin() in the baseplate firmware
WEBSOCKET_HOST = 'localhost'
WEBSOCKET_PORT = 8765

TARGET = TARGET_TOWER_3  # the construction the user is supposed to build

# Hand-over point between worker thread and websocket handler.
# maxsize=1 on purpose: the frontend only ever needs the NEWEST state,
# so if the browser is slow the old unread tree is dropped (see
# tree_worker) instead of queueing up a backlog of stale states.
tree_queue: Queue[dict] = Queue(maxsize=1)


# LED feedback frame for one actual tree (None = nothing built): the
# reader sends this as the reply to every payload frame. compare() runs
# here AND in evaluate_tree once per tree - trees are a handful of
# nodes, so recomputing is simpler than sharing the result across the
# reader/worker boundary.
def build_feedback_for_tree(actual) -> bytes:
    result = compare(actual, TARGET)
    return build_feedback_frame(led_states(result))


# orchestrator: actual tree (CubeNode or None) -> evaluated tree dict
# (parse happens in the source; feedback frame to the baseplate comes later)
def evaluate_tree(actual) -> dict:
    result = compare(actual, TARGET)
    return build_evaluated_tree(result)


#worker thread -> runs the serial reader in the background, compares every
#received tree against the target and puts the evaluated tree into the queue
def tree_worker() -> None:
    try:
        print(f"Starting serial reader on {SERIAL_PORT} at {BAUDRATE} baud.")

        # this for-loop drives the generator: each iteration resumes
        # iter_trees_from_binary_serial until its next `yield tree`
        for actual in iter_trees_from_binary_serial(
            SERIAL_PORT,
            BAUDRATE,
            feedback_builder=build_feedback_for_tree,
        ):
            evaluated = evaluate_tree(actual)

            # keep only the newest tree: drop the unread old one first
            if tree_queue.full():
                try:
                    tree_queue.get_nowait()
                except Empty:
                    # only possible if the handler grabbed it in between
                    # emptying and putting - then there is nothing to drop
                    pass
            tree_queue.put_nowait(evaluated)

    except Exception as error:
        # without this, an exception in the thread would disappear
        # silently (the main thread keeps running without a source)
        print(f"Tree worker stopped because of an error: {error}")


#websocket handler -> runs once per connected browser: sends the newest
#evaluated tree whenever one appears in the queue
async def handler(websocket) -> None:
    print("Browser connected.")

    try:
        while True:
            try:
                # non-blocking check; Queue has no async interface, so
                # polling + short sleep is the simplest bridge between
                # the thread world and the asyncio world
                tree = tree_queue.get_nowait()

            except Empty:
                # nothing new yet: yield control to the event loop for
                # 20 ms so this loop does not burn a CPU core
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
    # websockets.serve calls handler() once per connecting client
    async with websockets.serve(handler, WEBSOCKET_HOST, WEBSOCKET_PORT):
        print(
            f"WebSocket server started on "
            f"ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}"
        )
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    # daemon=True: the worker thread dies together with the main thread
    # on Ctrl+C instead of keeping the process alive
    worker_thread = Thread(
        target=tree_worker,
        daemon=True,
    )

    worker_thread.start()

    asyncio.run(main())
