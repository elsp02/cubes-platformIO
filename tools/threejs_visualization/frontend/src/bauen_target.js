// bauen_target.js - standalone fullscreen target-tree page.
//
// The selected target tree is rendered with the very same view used by
// the dashboard preview. This page deliberately has no WebSocket or
// server dependency.

import { TARGET_TREES } from "./target-tree/index.js";
import { createTargetTreeView } from "./visualization/target_tree_view.js";

const params = new URLSearchParams(window.location.search);
const treeId = params.get("tree");
const targetEntry = TARGET_TREES.find((entry) => entry.id === treeId);

if (!targetEntry) {
    console.warn(`Unknown tree id "${treeId}" - returning to dashboard.`);
    window.location.href = "index.html";
} else {
    const targetView = createTargetTreeView(
        document.getElementById("target-tree-canvas")
    );

    targetView.showTree(treeId);
}
