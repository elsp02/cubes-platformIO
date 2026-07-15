// main.js - frontend entry point (loaded by index.html as a module).
//
// Startup order:
//   1. initScene()        builds the three.js scene and starts the
//                         render loop (also kicks off the async GLB load)
//   2. connectWebSocket() opens the connection to ws_server.py and
//                         wires the two callbacks below
//
// After that everything is event-driven: each received tree triggers
// one redraw, a lost connection clears the scene.
import { initScene, redrawTree, clearTree } from "./scene_glb.js";
import { connectWebSocket } from "./ws_client.js";


initScene();

//connect to websocket server and redraw tree when data is received
connectWebSocket(
    // called for every received evaluated tree
    (tree) => {
        console.log("Received tree:", tree);
        redrawTree(tree); //in scene_glb.js, redraws the tree in the scene
    },
    // called when the connection closes or fails
    () => {
        console.log("Connection lost - clearing scene.");
        clearTree(); //no stale cubes when the server is gone
    }
);
