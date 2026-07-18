// bauen.js - entry point for bauen.html: shows the in-progress build
// (mock data for now, no live WebSocket yet - see [[buildMockProgressTree]])
// as a big scene, plus a target-tree preview widget that expands to fill
// the page on double-click.
//
// Which target tree to show comes from the URL (?tree=<id>), same
// convention as tree_preview.js, set by tree_selection.js.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import { loadCubeTemplate, buildTreeGroup, fitCameraToBox } from "./tree_builder.js";
import { TARGET_TREES } from "../target_trees/index.js";

// ------------------------------------------------------------
// Which tree to show
// ------------------------------------------------------------

const params = new URLSearchParams(window.location.search);
const treeId = params.get("tree");

const selectedEntry = TARGET_TREES.find((entry) => entry.id === treeId) ?? TARGET_TREES[0];

// ------------------------------------------------------------
// Mock build progress: clone the target tree, mark every cube "correct"
// except the last one visited depth-first, which becomes an
// "attachable" ghost - the next slot still waiting to be built.
// Replace this once real evaluated-tree data is available (see
// scene_glb.js / ws_client.js for the live equivalent).
// ------------------------------------------------------------

function buildMockProgressTree(targetTree) {
    const progressTree = structuredClone(targetTree);

    const allNodes = [];
    (function collect(node) {
        allNodes.push(node);
        for (const child of node.children ?? []) {
            collect(child);
        }
    })(progressTree);

    for (const node of allNodes) {
        node.status = "correct";
    }
    allNodes[allNodes.length - 1].status = "attachable";

    return {
        progressTree,
        totalCubes: allNodes.length,
        correctCubes: allNodes.length - 1,
    };
}

const { progressTree, totalCubes, correctCubes } = buildMockProgressTree(selectedEntry.tree);

// ------------------------------------------------------------
// progress bar
// ------------------------------------------------------------

const progressFill = document.getElementById("progress-fill");
progressFill.style.width = `${Math.round((correctCubes / totalCubes) * 100)}%`;

// ------------------------------------------------------------
// zurück -> back to the dashboard
// ------------------------------------------------------------

document.getElementById("zurück").addEventListener("click", () => {
    window.location.href = "index.html";
});

// ------------------------------------------------------------
// generic container-sized three.js viewer, shared setup for the big
// build scene and the corner target-tree preview
// ------------------------------------------------------------

function createViewer(container) {
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xfbfaf2);

    const camera = new THREE.PerspectiveCamera(60, 1, 0.1, 1000);
    camera.up.set(0, 0, 1);

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild(renderer.domElement);

    scene.add(new THREE.AmbientLight(0xffffff, 0.7));

    const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
    topLight.position.set(4, -5, 8);
    topLight.castShadow = true;
    scene.add(topLight);

    const ground = new THREE.Mesh(
        new THREE.PlaneGeometry(1000, 1000),
        new THREE.MeshStandardMaterial({ color: 0x757575, roughness: 0.8, metalness: 0.0 })
    );
    ground.receiveShadow = true;
    scene.add(ground);

    function resize() {
        const w = container.clientWidth || 1;
        const h = container.clientHeight || 1;

        renderer.setSize(w, h, false);
        camera.aspect = w / h;
        camera.updateProjectionMatrix();
    }
    resize();
    new ResizeObserver(resize).observe(container);

    return { scene, camera, renderer, ground };
}

// builds treeDefinition into a viewer and fits the camera/ground to it
function showTree(viewer, treeDefinition) {
    const treeGroup = buildTreeGroup(treeDefinition);
    viewer.scene.add(treeGroup);

    const box = new THREE.Box3().setFromObject(treeGroup);
    viewer.ground.position.z = box.min.z - 0.001;
    fitCameraToBox(viewer.camera, box);

    return box;
}

// ------------------------------------------------------------
// build once the shared cube model has loaded
// ------------------------------------------------------------

await loadCubeTemplate();

const buildViewer = createViewer(document.getElementById("build-scene"));
const buildBox = showTree(buildViewer, progressTree);

const buildControls = new OrbitControls(buildViewer.camera, buildViewer.renderer.domElement);
buildControls.enableDamping = true;
buildControls.enablePan = false;
buildControls.target.copy(buildBox.getCenter(new THREE.Vector3()));
buildControls.update();

const previewViewer = createViewer(document.getElementById("target-tree"));
showTree(previewViewer, selectedEntry.tree);

function animate() {
    requestAnimationFrame(animate);

    buildControls.update();
    buildViewer.renderer.render(buildViewer.scene, buildViewer.camera);
    previewViewer.renderer.render(previewViewer.scene, previewViewer.camera);
}
animate();

// ------------------------------------------------------------
// corner widget: double-click expands it to fill the page
// ------------------------------------------------------------

const previewWidget = document.getElementById("target-tree-container-window");
previewWidget.addEventListener("dblclick", () => {
    previewWidget.classList.toggle("is-expanded");
});
