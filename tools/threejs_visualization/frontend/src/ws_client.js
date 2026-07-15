// ws_client.js - websocket connection to the backend (ws_server.py).
//
// Message contract with the server: every message is JSON of the form
//   { "type": "evaluated_tree", "tree": { ...nested node dicts... } }
// where tree is what feedback_output.build_evaluated_tree() produced
// (node_id, status, error_mask, orientation, port, children, ...).
const WEBSOCKET_URL = "ws://localhost:8765";

// function is called in main.js to connect to the websocket server and receive tree data
// onTreeReceived(tree) is called for every valid tree message
// onDisconnected (optional) is called when the connection closes or fails
export function connectWebSocket(onTreeReceived, onDisconnected) {
    const socket = new WebSocket(WEBSOCKET_URL);

    // if connection is opened succesfully
    socket.onopen = () => {
        console.log("WebSocket connected:", WEBSOCKET_URL);

        // update status element in index.html
        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket connected";
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
        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket disconnected";
        }

        if (onDisconnected) {
            onDisconnected();
        }
    };

    // if error occurs
    socket.onerror = (error) => {
        console.error("WebSocket error:", error);

        // update status element in index.html
        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket error";
        }
    };

    return socket;
}
