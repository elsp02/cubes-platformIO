const WEBSOCKET_URL = "ws://localhost:8765";


export function connectWebSocket(onTreeReceived) {
    const socket = new WebSocket(WEBSOCKET_URL);

    socket.onopen = () => {
        console.log("WebSocket connected:", WEBSOCKET_URL);

        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket connected";
        }
    };

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

    socket.onclose = () => {
        console.log("WebSocket disconnected.");

        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket disconnected";
        }
    };

    socket.onerror = (error) => {
        console.error("WebSocket error:", error);

        const statusElement = document.getElementById("status");
        if (statusElement) {
            statusElement.textContent = "WebSocket error";
        }
    };

    return socket;
}