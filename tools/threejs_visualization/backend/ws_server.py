# this server sends one fake tree every second to the client 
# documentation on https://websockets.readthedocs.io/en/stable/intro/tutorial1.html
import asyncio
import json
import websockets
#from websockets.asyncio.server import serve

async def handler(websocket):
    counter = 0 # function: to generate different orientations for the child cube in each message
    while True:
        try:
            #message = await websocket.recv() # for what is this
            payload = {
                    "type": "tree",
                    "tree": {
                        "id": 0x44,
                        "orientation": counter % 4,
                        "port": None,
                        "children": [
                            {
                                "id": 0x45,
                                "orientation": 0,
                                "port": 0,
                                "children": []
                            }
                        ]
                    }
                }
            await websocket.send(json.dumps(payload))

            counter += 1
            await asyncio.sleep(1)  # wait for 1 second before sending the next message
        except websockets.ConnectionClosedOK:
            print("Connection closed")
            break
        #print(message)

async def main():
    async with websockets.serve(handler, "localhost", 8765):
        print("WebSocket server started on ws://localhost:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
