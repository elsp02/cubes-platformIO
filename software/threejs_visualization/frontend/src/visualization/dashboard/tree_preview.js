// tree_preview.js - dashboard adapter for the shared target-tree view.

import { createTargetTreeView } from "../views/target_tree_view.js";

const previewView = createTargetTreeView(
    document.getElementById("preview-canvas")
);

// showTargetTreePreview
// - shows the given tree in the dashboard's preview overlay
export function showTargetTreePreview(treeId) {
    return previewView.showTree(treeId);
}
