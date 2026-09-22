// ws_client.js
// - entry point: opens the WebSocket connection to the backend (ws_server.py)
//   and drives it through the sequence below, once per (re)connect
//
// Sequence (states, in order):
// 1. connecting     - new WebSocket(...) opens the connection
// 2. connected      - onopen fires; onConnected() lets the caller (re)send start_session
// 3. receiving      - onmessage fires for every server message; valid
//                     "evaluated_tree"/"tree" messages are handed to onTreeReceived()
// 4. disconnected   - onclose fires (clean close or after onerror);
//                     onDisconnected() runs, then reconnects after RECONNECT_DELAY_MS
//
// Message contract with the server: every message is JSON of the form
//   { "type": "evaluated_tree", "tree": { ...nested node dicts... } }
// where tree is what feedback_output.build_evaluated_tree() produced
// (node_id, status, error_mask, orientation, port, children, ...).


//--------------------------------
// Configuration
//--------------------------------
const WEBSOCKET_URL = "ws://localhost:8765";
const RECONNECT_DELAY_MS = 2000;

// the socket of the most recent connectWebSocket() call, so that
// sendMessage() always talks to the current connection (after a
// reconnect the old socket object is dead)
let activeSocket = null;

// sendMessage
// - sends a JSON message to the server (e.g. start_session from live_build.js)
// - false if the connection is not open right now
export function sendMessage(payload) {
    if (activeSocket && activeSocket.readyState === WebSocket.OPEN) {
        activeSocket.send(JSON.stringify(payload));
        return true;
    }
    console.warn("Cannot send, WebSocket is not open:", payload);
    return false;
}

//--------------------------------
// Connection handler
//--------------------------------

// connectWebSocket
// - called from live_build.js to open the connection and receive tree data
// - onTreeReceived(tree) fires for every valid tree message
// - onConnected fires on EVERY successful (re)connect, so the caller can (re)send start_session
// - onDisconnected (optional) fires when the connection closes or fails
export function connectWebSocket(onTreeReceived, onDisconnected, onConnected) {
    const socket = new WebSocket(WEBSOCKET_URL);
    activeSocket = socket;

    // true once onopen has fired for THIS socket, so onclose can tell a
    // "never connected" failure apart from a real disconnect afterwards
    let didConnect = false;

    // if connection is opened succesfully
    socket.onopen = () => {
        didConnect = true;
        console.log("WebSocket connected:", WEBSOCKET_URL);

        // update status element in index.html - currently not in use
        //const statusElement = document.getElementById("status");
        //if (statusElement) {
         //   statusElement.textContent = "WebSocket verbunden";
        //}

        //to hide loader page
        if (onConnected){
            onConnected();
        }
    };

    // if message is received from the server
    socket.onmessage = (event) => {
        try {
            const message = JSON.parse(event.data);

            // "evaluated_tree" = compared against target (new), "tree" = raw detection tree (old server)
            if (message.type !== "evaluated_tree" && message.type !== "tree") {
                console.warn("Ignored unknown WebSocket message:", message);
                return;
            }

            if (!message.tree) {
                console.warn("Received tree message without tree data:", message);
                return;
            }

            // hand the tree to main.js (which passes it to the renderer)
            onTreeReceived(message.tree);


        } catch (error) {
            // JSON.parse failed - the server sent something unreadable
            console.error("Could not parse WebSocket message:", error);
            console.error("Raw message:", event.data);
        }
    };

    // if the connection is closed (onerror is always followed by onclose,
    // so onDisconnected only needs to be called here)
    socket.onclose = () => {
        console.log("WebSocket disconnected.");

        // update status element in index.html - currently not in use
        //const statusElement = document.getElementById("status");
        /*if (statusElement) {
            statusElement.textContent = didConnect
                ? "WebSocket disconnected"
                : "Verbindung fehlgeschlagen - erneuter Versuch...";
        }*/

        if (onDisconnected) {
            onDisconnected();
        }

        // keep retrying to connect with server - no manual relaod necessary
        setTimeout(() => {
            connectWebSocket(onTreeReceived, onDisconnected, onConnected);
        }, RECONNECT_DELAY_MS);
    };

    // if error occurs
    socket.onerror = (error) => {
        console.error("WebSocket error:", error);

        // update status element in index.html - currently not in use
        //const statusElement = document.getElementById("status");
        //if (statusElement) {
            //statusElement.textContent = "WebSocket Fehler";
        //}
    };

    return socket;
}
