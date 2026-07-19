// bauen.js - entry module for bauen.html.
//
// Reads the tree/level the user picked on the dashboard (URL params set
// by tree_selection.js), connects to the websocket server and drives
// the loader with the connection state. On every (re)connect the full
// target tree JSON is sent as a start_session message - the server
// keeps no state across connections, so a reconnect simply restarts
// the session.
//
// Later steps: render evaluated trees into #main-tree-canvas, wire the
// X button (end_session).

import { connectWebSocket, sendMessage } from "./ws_client.js";
import { showLoader, hideLoader } from "./animation/loader_bauen.js";
import { TARGET_TREES } from "./target-tree/index.js";

const params = new URLSearchParams(window.location.search);
const treeId = params.get("tree");
const level = params.get("level");

// selectedTreeId on the dashboard is exactly the TARGET_TREES id ("tree1", ...)
const targetEntry = TARGET_TREES.find((entry) => entry.id === treeId);

if (!targetEntry) {
    // opened without a valid selection (e.g. direct URL) - back to the dashboard
    console.warn(`Unknown tree id "${treeId}" - returning to dashboard.`);
    window.location.href = "index.html";
} else {
    connectWebSocket(
        (tree) => {
            console.log("evaluated tree received:", tree);
        },
        () => {
            showLoader();
        },
        () => {
            // fires on every (re)connect: (re)start the session first,
            // only then reveal the page
            sendMessage({
                type: "start_session",
                tree: targetEntry.tree,
                level: level,
            });
            hideLoader();
        }
    );
}
