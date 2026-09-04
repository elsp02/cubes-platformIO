// tree_preview.js - dashboard adapter for the shared target-tree view.

import { createTargetTreeView } from "./target_tree_view.js";

const previewView = createTargetTreeView(
    document.getElementById("preview-canvas")
);

export function showTargetTreePreview(treeId) {
    return previewView.showTree(treeId);
}
