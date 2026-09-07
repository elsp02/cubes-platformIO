"""
ws_server.py
- entry point: opens the WebSocket server; handler() runs once per
  connected browser and drives that connection through the sequence below

Sequence (states, in order):
1. waits for connect  - websockets.serve() waits for a browser to connect
2. waits for start    - receive loop, ignores anything but start_session
3. session starts     - parse target tree, stop any previous session,
                        create + start Session, start the send_trees task
4. active session     - Session's worker thread compares every detected
                        tree and builds two "outputs":
                            -> build_feedback_frame() filters to present cubes and maps to green/red for the baseplate
                            -> build_evaluated_tree() merges the result back into the tree dict for the frontend 
                      - repeats until end_session or disconnect
5. sesssion ends/     - end_session received or the connection drops/crashes
   cleanup            - cancel send_trees, run stop_session() annd clear current_session
                        -> back to WAIT_FOR_CONNECT for the next browser

- one worker thread per session runs iter_trees_from_binary_serial()
  (binary_serial_reader.py); the asyncio event loop only talks to the
  browser - ?the two sides meet only at the session's queue?
"""

# (just for one client, no broadcasting)
# documentation on https://websockets.readthedocs.io/en/stable/intro/tutorial1.html
import asyncio
import json
from queue import Empty, Queue
from threading import Event, Thread
from typing import Optional

import websockets

from binary_serial_reader import iter_trees_from_binary_serial
from compare_core import compare
from feedback_output import build_evaluated_tree, build_feedback_frame, led_states
from target_tree import TargetNode, target_node_from_json

#--------------------------------
# Configuration
#--------------------------------
SERIAL_PORT = 'COM4'
BAUDRATE = 115200  # must match Serial.begin() in the baseplate firmware
WEBSOCKET_HOST = 'localhost'
WEBSOCKET_PORT = 8765

#--------------------------------
# Session
# - the build-session engine: target, queue, worker thread
#--------------------------------
"""
Session
- one build session (from start_session until end_session/disconnect):
  the user's chosen target tree, the queue handing evaluated trees to
  the browser side, and the serial worker thread that produces them
"""
class Session:
    """One build session: the user's chosen target tree + the serial
    worker thread that compares every detected tree against it."""

    def __init__(self, target: TargetNode) -> None:
        self.target = target

        # Hand-over point between worker thread and websocket handler.
        # fresh queue per session (no stale tree from a previous one);
        # maxsize=1 -> only the newest tree matters, a slow browser just
        # drops the old unread one instead of queueing a backlog
        self.queue: Queue[dict] = Queue(maxsize=1)

        self.stop_event = Event()

        # daemon=True: the worker dies together with the main thread
        self.thread = Thread(target=self._worker, daemon=True)

    def start(self) -> None:
        self.thread.start()

    """
    _feedback_for
    - LED feedback frame for one actual tree
      -> passed into binary_serial_reader.py as its feedback_builder callback,
        which calls this with every freshly parsed tree
    """
    def _feedback_for(self, actual) -> bytes:
        result = compare(actual, self.target) #in compare_core.py
        return build_feedback_frame(led_states(result)) # in feedback_output.py

    """
    _worker
    - runs in its own thread: 
        - drives iter_trees_from_binary_serial() -> communication with baseplate
        - compares every tree against the session target
        - builds the evaluated tree for the frontend/browser
        - puts each evaluated tree into self.queue -> send_trees() picks it up from there and forwards it to the browser
    """
    def _worker(self) -> None:
        try:
            print(f"Starting serial reader on {SERIAL_PORT} at {BAUDRATE} baud.")

            #1. communication with baseplate
            generator = iter_trees_from_binary_serial(
                SERIAL_PORT,
                BAUDRATE,
                feedback_builder=self._feedback_for, # hier wird der comparete tree an biary-serial_reader übergeben
                stop_event=self.stop_event,
            )
            try:
                # 2. comparing and building evaluated tree for browser
                # this for-loop drives the generator: 
                # each iteration resumes it until its next `yield tree`
                for actual in generator:
                    result = compare(actual, self.target) # incompare_core.py
                    evaluated = build_evaluated_tree(result) #in feedback_output.py

                    # 3. put evaluated tree into queue
                    # keep only the newest tree: drop the unread old one first
                    if self.queue.full():
                        try:
                            self.queue.get_nowait()
                        except Empty:
                            pass
                    self.queue.put_nowait(evaluated)
            finally:
                # 4. cleanup: 
                # runs the generator's finally block (CMD_STOP + port close)
                generator.close()

        # error handling
        except Exception as error:
            print(f"Session worker stopped because of an error: {error}")

# only one session can exist at a time (one serial port, one client);
session_lock = asyncio.Lock()
current_session: Optional[Session] = None

"""
stop_session
- ends a session: 
    - signals the serial worker to stop
    -  waits until its thread has exited (= CMD_STOP sent, COM port released)
"""
async def stop_session(session: Session) -> None:
    session.stop_event.set()

    # join in a helper thread so the event loop keeps running
    # -> worst case: reader needs ~1 s (serial timeout) to notice the event
    await asyncio.to_thread(session.thread.join, 5.0)

    if session.thread.is_alive():
        print("WARNING: serial worker did not stop within 5 s "
              "(COM port may still be in use).")


#--------------------------------
# Streaming to the browser
#--------------------------------
"""
send_trees
- sends the newest evaluated tree to the browser whenever one appears in the session queue
"""
async def send_trees(websocket, session: Session) -> None:
    while True:
        try:
            # non-blocking check
            tree = session.queue.get_nowait()

        except Empty:
            # nothing new yet
            await asyncio.sleep(0.02)
            continue

        payload = {
            "type": "evaluated_tree",
            "tree": tree,
        }
        # send evaluated tree to websocket client
        await websocket.send(json.dumps(payload))


#--------------------------------
# Connection handler
#--------------------------------
"""
handler
= communication layer to browser
- runs once per connected browser: 
    - reads every incoming message (start_session, end_session)
    - drives the Session lifecycle
- lifetime: WebSocket connection
"""
async def handler(websocket) -> None:
    global current_session

    print("Browser connected.")

    session: Optional[Session] = None
    sender: Optional[asyncio.Task] = None

    try:
        # receive loop:
        #  - async for yields every incoming message until the client disconnects 
        async for raw in websocket:
            try:
                message = json.loads(raw)
            except json.JSONDecodeError:
                print(f"Ignoring non-JSON message: {raw!r}")
                continue

            msg_type = message.get("type")

            #start_session:
            # - parses the target (target_tree.py)
            # - stops any previous session
            # - creates and starts a new Session + send_trees task
            if msg_type == "start_session":
                # one session per connection; the client only sends
                # start_session once per connect, anything else is a bug
                if session is not None:
                    print("Duplicate start_session ignored.")
                    continue

                # parses the target tree JSON the browser sent in start_session into a TargetNode
                try:
                    target = target_node_from_json(message["tree"]) #in target_tree.py
                except (KeyError, TypeError, ValueError) as error:
                    print(f"Invalid start_session message: {error}")
                    continue

                print(
                    f"start_session received: "
                    f"level={message.get('level')}, target={target}"
                )

                async with session_lock:
                    # stop previous session
                    if current_session is not None:
                        await stop_session(current_session)

                    session = Session(target)
                    current_session = session
                    session.start()   # serial opens, CMD_START goes out

                # starts the background task send_trees() that streams evaluated trees to
                # the browser as they appear in session.queue
                sender = asyncio.create_task(send_trees(websocket, session))


            # end_session: 
            # - only breaks the receive loop here
            # -> finally block below does the actual cleanup
            elif msg_type == "end_session":
                print("end_session received.")
                break

            else:
                print(f"Unknown message type: {msg_type}")

    #error handling -> abnormal close
    except websockets.ConnectionClosedError:
        print("Connection closed with error")

    # stops the session
    # -> runs no matter how the loop above ended 
    # (explicit end_session (break) or disconnect/crash (exception caught above))
    finally:
        # the send task must not outlive this connection
        if sender is not None:
            sender.cancel()

        if session is not None:
            async with session_lock:
                await stop_session(session)   # -> CMD_STOP, port released
                if current_session is session:
                    current_session = None
            print("Browser disconnected, session stopped.")
        else:
            print("Browser disconnected.")

#--------------------------------
# Entry point
#--------------------------------
async def main()-> None:
    # websockets.serve calls handler() once per connecting client
    async with websockets.serve(handler, WEBSOCKET_HOST, WEBSOCKET_PORT):
        print(
            f"WebSocket server started on "
            f"ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}"
        )
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    # as soon as a browser sends start_session, the serial reader is starts
    asyncio.run(main())
