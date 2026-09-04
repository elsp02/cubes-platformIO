// ws_client.js - websocket connection to the backend (ws_server.py).
//
// Message contract with the server: every message is JSON of the form
//   { "type": "evaluated_tree", "tree": { ...nested node dicts... } }
// where tree is what feedback_output.build_evaluated_tree() produced
// (node_id, status, error_mask, orientation, port, children, ...).
const WEBSOCKET_URL = "ws://localhost:8765";
const RECONNECT_DELAY_MS = 2000;

// the socket of the most recent connectWebSocket() call, so that
// sendMessage() always talks to the current connection (after a
// reconnect the old socket object is dead)
let activeSocket = null;

// send a JSON message to the server (e.g. start_session from bauen.js);
// returns false if the connection is not open right now
export function sendMessage(payload) {
    if (activeSocket && activeSocket.readyState === WebSocket.OPEN) {
        activeSocket.send(JSON.stringify(payload));
        return true;
    }
    console.warn("Cannot send, WebSocket is not open:", payload);
    return false;
}

// function is called in bauen.js to connect to the websocket server and receive tree data
// onTreeReceived(tree) is called for every valid tree message
// onDisconnected (optional) is called when the connection closes or fails
// onConnected is called on EVERY successful (re)connect - (re)send start_session
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

        // update status element in index.html
        //const statusElement = document.getElementById("status");
        //if (statusElement) {
         //   statusElement.textContent = "WebSocket connected";
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

        // update status element in index.html
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

        // update status element in index.html
        //const statusElement = document.getElementById("status");
        //if (statusElement) {
            //statusElement.textContent = "WebSocket error";
        //}
    };

    return socket;
}
