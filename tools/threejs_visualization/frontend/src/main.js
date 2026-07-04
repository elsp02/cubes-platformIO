import { initScene, redrawTree } from "./scene.js";
import { connectWebSocket } from "./ws_client.js";


initScene();

//connect to websocket server and redraw tree when data is received
connectWebSocket((tree) => {
    console.log("Received tree:", tree);
    redrawTree(tree); //in scene.js, redraws the tree in the scene
});