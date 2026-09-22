// build_reference_test.js - TEMPORARY test entry for build_reference_test.html.
//
// Feeds a hardcoded fake "evaluated tree" straight into live_view.js and
// reference_view.js, bypassing ws_client.js entirely - so the split
// view can be checked visually without a running backend or hardware.
// Not linked from anywhere else; delete both files once the layout is
// confirmed.
//
// Shape matches what the real backend sends (see ws_client.js's comment
// and tree_builder.js's nodeView()): node_id, status, error_mask,
// orientation, port, children for real cubes; expected_type/
// expected_orientation instead of node_id for ghost/not-yet-built slots.
// Topology mirrors target-tree/tree3.json (root + 1 child + 2 grandchildren).

import { initScene, redrawTree } from "./visualization/views/live_view.js";
import { createComparisonView } from "./visualization/views/reference_view.js";
import { hideLoader } from "./animation/loader_live_build.js";
import "./ui/split_toggle.js";

const TYPE_CUBE = 0;
const TYPE_SMASHED = 1;

const fakeEvaluatedTree = {
    node_id: (TYPE_SMASHED << 5) | 0,
    status: "correct",
    error_mask: 0,
    orientation: 0,
    port: null,
    children: [
        {
            node_id: (TYPE_CUBE << 5) | 0,
            status: "correct",
            error_mask: 0,
            orientation: 1,
            port: 0,
            children: [
                {
                    node_id: (TYPE_CUBE << 5) | 1,
                    status: "wrong",
                    error_mask: 1,
                    orientation: 1,
                    port: 1,
                    children: [
                        {
                            // blocked: parent is wrong, so this slot can't be
                            // evaluated yet - hidden on the right, still
                            // visible (untinted) on the left
                            status: "blocked",
                            expected_type: TYPE_CUBE,
                            expected_orientation: 0,
                            port: 0,
                            children: [],
                        },
                    ],
                },
                {
                    // attachable: not built yet, but reachable next
                    status: "attachable",
                    expected_type: TYPE_CUBE,
                    expected_orientation: 1,
                    port: 4,
                    children: [],
                },
            ],
        },
    ],
};

initScene(document.getElementById("main-tree-canvas"));
const comparisonView = createComparisonView(document.getElementById("comparison-tree-canvas"));

redrawTree(fakeEvaluatedTree);
comparisonView.redrawTree(fakeEvaluatedTree);

hideLoader();
