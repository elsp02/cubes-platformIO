const output = document.getElementById("output");

const socket = new WebSocket("ws://localhost:8765");

socket.onopen = () => {
    output.textContent = "Connected to WebSocket server.";
};

socket.onmessage = (event) => {
    const message = JSON.parse(event.data);
    output.textContent = JSON.stringify(message, null, 2);
};

socket.onclose = () => {
    output.textContent = "WebSocket closed.";
};

socket.onerror = () => {
    output.textContent = "WebSocket error.";
};