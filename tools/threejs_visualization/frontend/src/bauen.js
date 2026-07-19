// bauen.js - entry module for bauen.html.
//
// Step 1: connect to the websocket server and drive the loader with the
// connection state. The loader stays up until the server is reachable
// and reappears whenever the connection drops (ws_client.js retries
// every 2s on its own).
//
// Later steps: send the selected target tree (URL params tree/level),
// render evaluated trees into #main-tree-canvas, wire the X button.

import { connectWebSocket } from "./ws_client.js";
import { showLoader, hideLoader } from "./animation/loader_bauen.js";

connectWebSocket(
    (tree) => {
        console.log("evaluated tree received:", tree);
    },
    () => {
        showLoader();
    },
    () => {
        hideLoader();
    }
);
