const WEBSOCKET_URL = "ws://localhost:8765";

// function is called in main.js to connect to the websocket server and receive tree data
export function connectWebSocket(onTreeReceived) {
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

            if (message.type !== "tree") {
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

    // if the connection is closed
    socket.onclose = () => {
        console.log("WebSocket disconnected.");

        // update status element in index.html
        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket disconnected";
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