const WEBSOCKET_URL = "ws://localhost:8765";

// function is called in main.js to connect to the websocket server and receive tree data
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

            onTreeReceived(message.tree);
            

        } catch (error) {
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