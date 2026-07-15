import { initScene, redrawTree, clearTree } from "./scene_glb.js";
import { connectWebSocket } from "./ws_client.js";


initScene();

//connect to websocket server and redraw tree when data is received
connectWebSocket(
    (tree) => {
        console.log("Received tree:", tree);
        redrawTree(tree); //in scene_glb.js, redraws the tree in the scene
    },
    () => {
        console.log("Connection lost - clearing scene.");
        clearTree(); //no stale cubes when the server is gone
    }
);