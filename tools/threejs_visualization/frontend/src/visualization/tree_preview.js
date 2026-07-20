// tree_preview.js - shows ONE target tree, chosen on the dashboard,
// live and orbit-able inside the #preview-canvas overlay.
//
// Which tree to show is passed in by tree_selection.js (from the
// clicked card's id) via showTargetTreePreview(). Container-sized
// renderer + OrbitControls, same interactive-view pattern as
// scene_test.js - but the geometry comes from buildTreeGroup() instead
// of a single fixed cube, and there is no status/tint logic: target
// trees have no status.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import { loadCubeTemplate, buildTreeGroup, fitCameraToBox } from "./tree_builder.js";
import { addSceneEnvironment, placeGroundUnderBox } from "./scene_environment.js";
import { TARGET_TREES } from "../target-tree/index.js";

// ------------------------------------------------------------
// Scene setup (container-sized, not fullscreen)
// ------------------------------------------------------------

const container = document.getElementById("preview-canvas");
if (!container) {
    throw new Error("#target-tree wurde nicht gefunden.");
}

const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(60, 1, 0.1, 1000);
camera.up.set(0, 0, 1);

const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
container.appendChild(renderer.domElement);

function resizeToContainer() {
    const w = container.clientWidth || 1;
    const h = container.clientHeight || 1;

    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
}
resizeToContainer();

const ro = new ResizeObserver(resizeToContainer);
ro.observe(container);


// ------------------------------------------------------------
// Lights + ground (shared environment, same as thumbnail + live view)
// ------------------------------------------------------------

const { ground } = addSceneEnvironment(scene);


// ------------------------------------------------------------
// OrbitControls
// ------------------------------------------------------------

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = false;
// Kamera nie unter die Bodenebene kippen lassen (Z-up: PI/2 = horizontal)
controls.maxPolarAngle = Math.PI / 2;

controls.touches = {
    ONE: THREE.TOUCH.ROTATE,
    TWO: THREE.TOUCH.DOLLY_ROTATE,
};

controls.autoRotate = true;
controls.autoRotateSpeed = 2.0; // three.js default: ~30s per full turn, a slow idle spin

// permanently stop the auto-spin the first time the user takes over;
// OrbitControls itself keeps working as normal, only the automatic
// rotation turns off
controls.addEventListener("start", () => {
    controls.autoRotate = false;
});

renderer.domElement.style.touchAction = "none";
renderer.domElement.addEventListener("wheel", (e) => e.preventDefault(), { passive: false });


// ------------------------------------------------------------
// Swap in a different target tree, called by tree_selection.js
// whenever the user picks a card.
// ------------------------------------------------------------

let currentTreeGroup = null;
const cubeTemplateReady = loadCubeTemplate();

export async function showTargetTreePreview(treeId) {
    const entry = TARGET_TREES.find((candidate) => candidate.id === treeId);
    if (!entry) {
        console.warn(`Unknown target tree id: "${treeId}"`);
        return;
    }

    await cubeTemplateReady;

    if (currentTreeGroup) {
        scene.remove(currentTreeGroup);
    }

    currentTreeGroup = buildTreeGroup(entry.tree);
    scene.add(currentTreeGroup);

    const box = new THREE.Box3().setFromObject(currentTreeGroup);
    placeGroundUnderBox(ground, box);

    fitCameraToBox(camera, box);
    controls.target.copy(box.getCenter(new THREE.Vector3()));
    controls.update();

    console.log(`Showing target tree "${entry.name}".`);
}


// ------------------------------------------------------------
// Render loop
// ------------------------------------------------------------

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
}
animate();
