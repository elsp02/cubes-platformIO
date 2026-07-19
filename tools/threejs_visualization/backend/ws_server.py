# WebSocket server: the glue between baseplate, comparison and frontend.
#
# Position in the pipeline:
#
#   real baseplate (binary_serial_reader)
#       --CubeNode tree--> compare against the session target
#           --evaluated dict--> --JSON over websocket--> three.js frontend
#   and back: compare result --feedback frame--> baseplate --> cube LEDs
#
# Session lifecycle (since the frontend picks the target tree itself):
#
#   browser connects
#       -> sends {"type": "start_session", "tree": ..., "level": ...}
#       -> Session starts: serial opens, CMD_START goes to the baseplate
#       -> evaluated trees stream back to the browser
#   browser sends end_session OR disconnects (tab closed, reload, crash)
#       -> serial worker stops, CMD_STOP goes to the baseplate
#
# Architecture: the serial reader blocks on the serial port, so it runs
# in its own worker THREAD (one per session). The websocket part runs in
# the asyncio event loop of the main thread. The two sides only meet at
# the session's queue.
#
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
SERIAL_PORT = 'COM4'  # Change this to your serial port
BAUDRATE = 115200  # must match Serial.begin() in the baseplate firmware
WEBSOCKET_HOST = 'localhost'
WEBSOCKET_PORT = 8765


class Session:
    """One build session: the user's chosen target tree + the serial
    worker thread that compares every detected tree against it."""

    def __init__(self, target: TargetNode) -> None:
        self.target = target

        # Hand-over point between worker thread and websocket handler.
        # A FRESH queue per session, so a new session can never receive
        # a stale tree left over from the previous one. maxsize=1 on
        # purpose: the frontend only ever needs the NEWEST state, so if
        # the browser is slow the old unread tree is dropped instead of
        # queueing up a backlog of stale states.
        self.queue: Queue[dict] = Queue(maxsize=1)

        # set from the asyncio side to end the session; the serial
        # reader checks it once per loop iteration (~1 s worst case)
        self.stop_event = Event()

        # daemon=True: the worker dies together with the main thread
        # on Ctrl+C instead of keeping the process alive
        self.thread = Thread(target=self._worker, daemon=True)

    def start(self) -> None:
        self.thread.start()

    # LED feedback frame for one actual tree (None = nothing built): the
    # reader sends this as the reply to every payload frame. compare()
    # runs here AND for the evaluated tree - trees are a handful of
    # nodes, so recomputing is simpler than sharing the result across
    # the reader/worker boundary.
    def _feedback_for(self, actual) -> bytes:
        result = compare(actual, self.target)
        return build_feedback_frame(led_states(result))

    #worker thread -> runs the serial reader in the background, compares
    #every received tree against the session target and puts the
    #evaluated tree into the queue
    def _worker(self) -> None:
        try:
            print(f"Starting serial reader on {SERIAL_PORT} at {BAUDRATE} baud.")

            generator = iter_trees_from_binary_serial(
                SERIAL_PORT,
                BAUDRATE,
                feedback_builder=self._feedback_for,
                stop_event=self.stop_event,
            )
            try:
                # this for-loop drives the generator: each iteration
                # resumes it until its next `yield tree`
                for actual in generator:
                    result = compare(actual, self.target)
                    evaluated = build_evaluated_tree(result)

                    # keep only the newest tree: drop the unread old one first
                    if self.queue.full():
                        try:
                            self.queue.get_nowait()
                        except Empty:
                            # only possible if the handler grabbed it in
                            # between emptying and putting - then there
                            # is nothing to drop
                            pass
                    self.queue.put_nowait(evaluated)
            finally:
                # deterministic cleanup: runs the generator's finally
                # block NOW (CMD_STOP + port close) instead of whenever
                # the garbage collector gets around to it
                generator.close()

        except Exception as error:
            # without this, an exception in the thread would disappear
            # silently (the main thread keeps running without a source)
            print(f"Session worker stopped because of an error: {error}")


# only one session can exist at a time (one serial port, one client);
# the lock makes sure a new session waits until the previous worker has
# really released the COM port - Windows refuses to reopen it otherwise
session_lock = asyncio.Lock()
current_session: Optional[Session] = None


async def stop_session(session: Session) -> None:
    """End a session: signal the serial worker to stop and wait until
    its thread has exited (= CMD_STOP sent, COM port released)."""
    session.stop_event.set()

    # join in a helper thread so the event loop keeps running; worst
    # case the reader needs ~1 s (serial timeout) to notice the event
    await asyncio.to_thread(session.thread.join, 5.0)

    if session.thread.is_alive():
        print("WARNING: serial worker did not stop within 5 s "
              "(COM port may still be in use).")


#send loop -> runs as a background task per connection: sends the newest
#evaluated tree whenever one appears in the session queue
async def send_trees(websocket, session: Session) -> None:
    while True:
        try:
            # non-blocking check; Queue has no async interface, so
            # polling + short sleep is the simplest bridge between
            # the thread world and the asyncio world
            tree = session.queue.get_nowait()

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


#websocket handler -> runs once per connected browser: receives messages
#from the client and drives the session lifecycle, while a background
#task streams evaluated trees back
async def handler(websocket) -> None:
    global current_session

    print("Browser connected.")

    session: Optional[Session] = None
    sender: Optional[asyncio.Task] = None

    try:
        # async for yields every incoming message until the client
        # disconnects (this is the receive loop)
        async for raw in websocket:
            try:
                message = json.loads(raw)
            except json.JSONDecodeError:
                print(f"Ignoring non-JSON message: {raw!r}")
                continue

            msg_type = message.get("type")

            if msg_type == "start_session":
                # one session per connection; the client only sends
                # start_session once per connect, anything else is a bug
                if session is not None:
                    print("Duplicate start_session ignored.")
                    continue

                try:
                    target = target_node_from_json(message["tree"])
                except (KeyError, TypeError, ValueError) as error:
                    print(f"Invalid start_session message: {error}")
                    continue

                print(
                    f"start_session received: "
                    f"level={message.get('level')}, target={target}"
                )

                async with session_lock:
                    # a previous connection's session may still be
                    # shutting down (e.g. page reload): stop it and wait,
                    # so the COM port is free before reopening it
                    if current_session is not None:
                        await stop_session(current_session)

                    session = Session(target)
                    current_session = session
                    session.start()   # serial opens, CMD_START goes out

                sender = asyncio.create_task(send_trees(websocket, session))

            elif msg_type == "end_session":
                # explicit end (X button): leave the receive loop, the
                # finally block below does the actual cleanup - exactly
                # like an implicit end via disconnect
                print("end_session received.")
                break

            else:
                print(f"Unknown message type: {msg_type}")

    #a clean disconnect just ends the async-for loop WITHOUT raising,
    #so this except only catches abnormal closes (crash, network drop)
    except websockets.ConnectionClosedError:
        print("Connection closed with error")

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


async def main()-> None:
    # websockets.serve calls handler() once per connecting client
    async with websockets.serve(handler, WEBSOCKET_HOST, WEBSOCKET_PORT):
        print(
            f"WebSocket server started on "
            f"ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}"
        )
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    # no serial thread at startup anymore: the serial reader is started
    # per session, as soon as a browser sends start_session
    asyncio.run(main())
