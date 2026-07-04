import { initScene, redrawTree } from "./scene.js";
import { connectWebSocket } from "./ws_client.js";


initScene();

connectWebSocket((tree) => {
    console.log("Received tree:", tree);
    redrawTree(tree);
});