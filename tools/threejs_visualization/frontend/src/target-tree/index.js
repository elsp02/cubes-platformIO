// index.js - collects all target tree JSON files into one list.

import tree1 from "./tree1.json";
import tree2 from "./tree2.json";
import tree3 from "./tree3.json";

export const TARGET_TREES = [
    { id: "tree1", name: "Baum 1", tree: tree1 },
    { id: "tree2", name: "Baum 2", tree: tree2 },
    { id: "tree3", name: "Baum 3", tree: tree3 },
];
