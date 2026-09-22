// tree_thumbnail.js - renders every target tree once and snapshots it
// as a PNG, to build the dashboard's target-tree cards

import * as THREE from "three";

import { loadCubeTemplate, buildTreeGroup, fitCameraToBox } from "../core/tree_builder.js";
import { addSceneEnvironment, placeGroundUnderBox } from "../core/scene_environment.js";
import { TARGET_TREES } from "../../target-tree/index.js";

//Resolution/ratio for the thumbnail snapshot to match the 3:4 ratio of the cards
const THUMBNAIL_WIDTH = 800;
const THUMBNAIL_HEIGHT = 600;

//--------------------------------------------------------
// Thumbnail rendering
// - one throwaway WebGL scene per tree, rendered once to a PNG data URL
//--------------------------------------------------------

// renderTreeToImage
// - builds a small scene around the tree and snapshots it as a PNG data URL
function renderTreeToImage(treeDefinition) {
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT, false);
    renderer.setPixelRatio(1); // fixed output resolution, DPR-independent
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    //initialize scene with the shared environment (background, lights,
    //shadow ground) -> thumbnail looks exactly like preview + live view
    const scene = new THREE.Scene();
    const { ground } = addSceneEnvironment(scene);

    //add Tree construction
    const treeGroup = buildTreeGroup(treeDefinition);
    // to also show the root marker (frame + front arrow) here:
    // const treeGroup = buildTreeGroup(treeDefinition, null, { showRootMarker: true });
    scene.add(treeGroup);

    // ground directly under the lowest cube, receives the shadows
    const box = new THREE.Box3().setFromObject(treeGroup);
    placeGroundUnderBox(ground, box);

    // add camera - fit camera to box calculates the best position
    const camera = new THREE.PerspectiveCamera(
        60,
        THUMBNAIL_WIDTH / THUMBNAIL_HEIGHT,
        0.1,
        1000
    );
    camera.up.set(0, 0, 1);
    fitCameraToBox(camera, box);

    renderer.render(scene, camera);

    const dataUrl = renderer.domElement.toDataURL("image/png");

    renderer.dispose(); // free the WebGL context right away

    return dataUrl;
}

//--------------------------------------------------------
// Card creation
//--------------------------------------------------------

// showTargetTreeThumbnails
// - creates one dashboard card per entry in TARGET_TREES (target-tree/index.js)
async function showTargetTreeThumbnails() {
    try {
        await loadCubeTemplate();

        const scrollContainer = document.getElementById("scroll-container-dashboard");

        for (const { id, name, tree } of TARGET_TREES) {
            const dataUrl = renderTreeToImage(tree);

            const card = document.createElement("div");
            card.className = "card aspect-ratio-4-3 horizontal";
            card.id = `card-${id}`;

            const img = document.createElement("img");
            img.src = dataUrl;
            img.alt = `Zielbaum: ${name}`;

            card.append(img);
            scrollContainer.append(card);
        }

        console.log(`Created ${TARGET_TREES.length} target tree cards.`);
        document.dispatchEvent(new CustomEvent("cards-ready"));
    } catch (error) {
        console.error("Could not create target tree thumbnails:", error);
    }
}

showTargetTreeThumbnails();
