// bauen.js - entry module for bauen.html.
//
// 1. Reads the tree/level the user picked on the dashboard (URL params set
// by tree_selection.js)
// 2. connects to the websocket server and drives the loader with the connection state. 
// On every (re)connect the full target tree JSON is sent as a start_session message - the server
// 3. Every evaluated tree the server sends back is rendered into #main-tree-canvas.
//
// Later steps: wire the X button (end_session).

import { connectWebSocket, sendMessage } from "./ws_client.js";
import { showLoader, hideLoader } from "./animation/loader_bauen.js";
import { initScene, redrawTree, clearTree } from "./visualization/scene_glb.js";
import { TARGET_TREES, countBlocks } from "./target-tree/index.js";
import { updateProgress } from "./progress_bar.js";
import { openEndDialog } from "./animation/end_dialog.js";

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
    initScene(document.getElementById("main-tree-canvas"));

    // total block count never changes during a session -> compute once
    const totalBlocks = countBlocks(targetEntry.tree);

    // true once the "fully built" dialog has been shown, so it doesn't
    // reopen on every tree update while the construction stays complete;
    // reset if the count drops below total (e.g. a cube gets removed)
    let completionDialogShown = false;

    function endSessionAndReturn() {
        sendMessage({ type: "end_session" });
        window.location.href = "index.html";
    }

    document.getElementById("zurück-button-dashboard").addEventListener("click", () => {
        openEndDialog("Wirklich beenden?", endSessionAndReturn, true);
    });

    connectWebSocket( //exported function from ws_client.js
        (tree) => {
            const { correctCount } = redrawTree(tree);
            updateProgress(correctCount, totalBlocks);

            if (correctCount === totalBlocks) {
                if (!completionDialogShown) {
                    completionDialogShown = true;
                    openEndDialog("Fertig, gut gemacht!", endSessionAndReturn, false);
                }
            } else {
                completionDialogShown = false;
            }
        },
        () => {
            // connection lost: never show stale build state
            clearTree();
            showLoader();
        },
        () => {
            // fires on every (re)connect: (re)start the session first,
            // only then reveal the page
            sendMessage({ //exported function from ws_client.js 
                type: "start_session",
                tree: targetEntry.tree,
                level: level,
            });
            hideLoader();
        }
    );
}
