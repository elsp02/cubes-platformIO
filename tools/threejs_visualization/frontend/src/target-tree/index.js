// index.js - collects all target tree JSON files into one list.

import tree1 from "./tree1.json";
import tree2 from "./tree2.json";
import tree3 from "./tree3.json";
import tree4 from "./tree4.json";

export const TARGET_TREES = [
    { id: "tree1", name: "Baum 1", tree: tree1 },
    { id: "tree2", name: "Baum 2", tree: tree2 },
    { id: "tree3", name: "Baum 3", tree: tree3 },
    { id: "tree4", name: "Baum 4", tree: tree4 },
];

// total number of cubes in a target tree (root + all nested children) -
// used as the denominator for the build progress bar
export function countBlocks(node) {
    return 1 + node.children.reduce((sum, child) => sum + countBlocks(child), 0);
}
