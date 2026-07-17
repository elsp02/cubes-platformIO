// target_tree_visualization.js - renders a TARGET tree (the goal the
// kids should build) as a preview image for the selection cards.
//
// Approach: ONE hidden renderer draws the tree a single time, the
// result is copied out as a PNG data URL (toDataURL) and used as the
// src of the card <img> elements. After that no WebGL is running for
// the cards at all - they are ordinary images, so scrolling/snapping
// stays cheap and there is no per-card WebGL context.
//
// A target tree has NO node ids and NO status (correct/wrong/ghost):
// it describes cubes that do not physically exist yet. A node is only
//   { orientation, port, children }   (root without port)
// The pose math is shared with the live view (layout.js), so the
// preview is guaranteed to stack exactly like the real visualization.
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

import {
    localPoseForRoot,
    localPoseForChild,
} from "../../src/layout.js";


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

// page-relative: the html lives in /test/, the model in /test/assets/
const CUBE_MODEL_URL = "./assets/cube_model_z.glb";

// same scale as in scene_test.js / src/scene_glb.js
const MODEL_SCALE = 25.0;

// thumbnail resolution; 3:4 to match the .aspect-ratio-3-4 cards
const THUMBNAIL_WIDTH = 600;
const THUMBNAIL_HEIGHT = 800;

// demo target tree: root cube with one cube stacked on top (port 4 =
// +Z) and twisted by 90° (orientation 1) so a wrong rotation would be
// visible in the preview.
// TODO later: several trees (one per card), loaded from a shared
// definition file that the dialog text and the live scene also use.
const TARGET_TREE = {
    orientation: 0,
    children: [
        { port: 4, orientation: 1, children: [] },
    ],
};


// Z is the vertical axis, same convention as the rest of the frontend
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);


// ------------------------------------------------------------
// Model loading
//
// Same template pattern as scene_glb.js: the GLB is fetched once and
// every drawn cube is a clone. Wrapped in a promise so the thumbnail
// code can simply await it.
// ------------------------------------------------------------

let cubeTemplate = null;

function loadCubeTemplate() {
    //was ist new Promise
    return new Promise((resolve, reject) => {
        const loader = new GLTFLoader();

        loader.load(
            CUBE_MODEL_URL,

            (gltf) => {
                cubeTemplate = gltf.scene;

                // enable shadows on every mesh inside the model
                cubeTemplate.traverse((object) => {
                    if (object.isMesh) {
                        object.castShadow = true;
                        object.receiveShadow = true;
                    }
                });

                resolve();
            },

            undefined, // progress callback, not needed

            (error) => reject(error)
        );
    });
}


// ------------------------------------------------------------
// Tree building (adapted from scene_glb.js addCubeRecursive, but
// without any status/ghost/blocked handling - every node is drawn in
// the original GLB look)
// ------------------------------------------------------------

// pure function: target tree definition -> THREE.Group of nested cubes.
// Exported so the later live scene (after the OK click) can build the
// SAME tree from the SAME definition.
export function buildTreeGroup(rootNode) {
    const treeGroup = new THREE.Group();
    treeGroup.name = "targetTreeGroup";

    addCubeRecursive(rootNode, treeGroup, true);

    return treeGroup;
}

// walks the tree depth-first and mirrors it as nested three.js groups:
// each cube is a CHILD of its parent's group, so the local poses from
// layout.js are automatically stacked up the chain
function addCubeRecursive(node, parentObject, isRoot) {
    if (cubeTemplate === null) {
        throw new Error("Cube model is not loaded yet.");
    }

    const cubeObject = new THREE.Group();

    // clone(true) = deep clone including all child meshes; materials
    // stay shared, which is fine here because nothing gets tinted
    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);
    cubeObject.add(visualModel);

    const pose = isRoot
        ? localPoseForRoot(node)
        : localPoseForChild(node);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject);

    for (const child of node.children ?? []) {
        addCubeRecursive(child, cubeObject, false);
    }
}


// ------------------------------------------------------------
// Thumbnail rendering (offscreen, one shot)
// ------------------------------------------------------------

// same framing idea as fitCameraToCube in scene_test.js: bounding box
// of the whole tree, camera diagonally from the front, slightly above
function fitCameraToBox(camera, box) {
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = THREE.MathUtils.degToRad(camera.fov);
    let dist = (maxDim / 2) / Math.tan(fov / 2);
    dist *= 1.6; // a bit of air around the tree

    const dir = new THREE.Vector3(1, -1.2, 0.8).normalize();
    camera.position.copy(center).addScaledVector(dir, dist);

    camera.near = dist / 100;
    camera.far = dist * 100;
    camera.lookAt(center);
    camera.updateProjectionMatrix();
}

// builds a small scene around the tree, renders it ONCE and returns
// the image as a PNG data URL. The renderer is created and disposed
// inside this function - nothing keeps running afterwards.
function renderTreeToImage(treeDefinition) {
    // never appended to the DOM: the canvas only exists to be copied
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT, false);
    renderer.setPixelRatio(1); // fixed output resolution, DPR-independent
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xfbfaf2); // page background color

    // same light setup as scene_test.js, so the preview matches the look
    scene.add(new THREE.AmbientLight(0xffffff, 0.7));

    const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
    topLight.position.set(4, -5, 8);
    topLight.castShadow = true;
    scene.add(topLight);

    const treeGroup = buildTreeGroup(treeDefinition);
    scene.add(treeGroup);

    // ground directly under the lowest cube, receives the shadows
    const box = new THREE.Box3().setFromObject(treeGroup);

    const ground = new THREE.Mesh(
        new THREE.PlaneGeometry(1000, 1000),
        new THREE.MeshStandardMaterial({
            color: 0x757575,
            roughness: 0.8,
            metalness: 0.0,
        })
    );
    ground.receiveShadow = true;
    ground.position.z = box.min.z - 0.001;
    scene.add(ground);

    const camera = new THREE.PerspectiveCamera(
        60,
        THUMBNAIL_WIDTH / THUMBNAIL_HEIGHT,
        0.1,
        1000
    );
    camera.up.set(0, 0, 1);
    fitCameraToBox(camera, box);

    renderer.render(scene, camera);

    // must happen in the SAME tick as render(): the browser may clear
    // the WebGL drawing buffer afterwards (no preserveDrawingBuffer)
    const dataUrl = renderer.domElement.toDataURL("image/png");

    renderer.dispose(); // free the WebGL context right away

    return dataUrl;
}


// ------------------------------------------------------------
// Card wiring
// ------------------------------------------------------------

// for now the SAME tree goes on all three cards (testing only);
// later: one tree per card via data-tree-id
async function showTargetTreeThumbnails() {
    try {
        await loadCubeTemplate();

        const dataUrl = renderTreeToImage(TARGET_TREE);

        const cardImages = document.querySelectorAll(".scroll-container .card img");

        for (const img of cardImages) {
            img.src = dataUrl;
            img.alt = "Zielbaum: zwei gestapelte Würfel";
        }

        console.log(`Target tree thumbnail set on ${cardImages.length} cards.`);
    } catch (error) {
        console.error("Could not create target tree thumbnail:", error);
    }
}

showTargetTreeThumbnails();
