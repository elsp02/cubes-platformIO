# this server sends the tree in json to the websocket client  (just for one client, no broadcasting)
# documentation on https://websockets.readthedocs.io/en/stable/intro/tutorial1.html
import asyncio
import json
import websockets
from queue import Empty, Queue
from threading import Thread
#from websockets.asyncio.server import serve
from binary_serial_reader import iter_trees_from_binary_serial
from cube_node import tree_to_dict

#--------------------------------
# Configuration
# hier error messages miteinbauen
#--------------------------------
SERIAL_PORT = 'COM4'  # Change this to your serial port
BAUDRATE = 9600
WEBSOCKET_HOST = 'localhost'
WEBSOCKET_PORT = 8765

#stores only the newest received tree
tree_queue: Queue[dict] = Queue(maxsize=1)

#serial thread -> runs the serial reader in the background and puts the received trees into the queue
# converts binary payload -> CubeNode tree -> Python dict
def serial_worker() -> None:
    print(f"Starting serial reader on {SERIAL_PORT} at {BAUDRATE} baud.")

    try:
        for tree in iter_trees_from_binary_serial(SERIAL_PORT, BAUDRATE):
            tree_dict = tree_to_dict(tree)
            
            if tree_queue.full():
                try:
                    tree_queue.put_nowait(tree_dict)
                except Empty:
                    pass
            tree_queue.put_nowait(tree_dict)

    except Exception as error:
        print(f"Serial worker stopped because of an error: {error}")

#websocket handler -> Sends the newest tree to the connected browser




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
                "type": "tree",
                "tree": tree,
            }
            # send tree to websocket client
            await websocket.send(json.dumps(payload))
            #print(message)

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
    serial_thread = Thread(
        target=serial_worker,
        daemon=True,
    )

    serial_thread.start()

    asyncio.run(main())
