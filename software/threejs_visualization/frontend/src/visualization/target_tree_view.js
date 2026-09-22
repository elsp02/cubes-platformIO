// target_tree_view.js - interactive target-tree renderer.


import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import { loadCubeTemplate, buildTreeGroup, fitCameraToBox } from "./tree_builder.js";
import { addSceneEnvironment, placeGroundUnderBox } from "./scene_environment.js";
import { TARGET_TREES } from "../target-tree/index.js";

// createTargetTreeView
// - sets up an independent scene/camera/renderer/OrbitControls for the
//   given container; returns { showTree } to load a target tree into it
export function createTargetTreeView(container) {
    if (!container) {
        throw new Error("Container für die Target-Tree-Ansicht wurde nicht gefunden.");
    }

    const scene = new THREE.Scene();

    const camera = new THREE.PerspectiveCamera(60, 1, 0.1, 1000);
    camera.up.set(0, 0, 1);

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild(renderer.domElement);

     // resizeToContainer
    function resizeToContainer() {
        const width = container.clientWidth || 1;
        const height = container.clientHeight || 1;

        renderer.setSize(width, height, false);
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
    }

    resizeToContainer();

    // keep the renderer/camera in sync if the container itself is resized
    const resizeObserver = new ResizeObserver(resizeToContainer);
    resizeObserver.observe(container);

    const { ground } = addSceneEnvironment(scene);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;          // smooths out orbit/zoom motion
    controls.enablePan = false;             // only rotate/zoom, no dragging the target around
    controls.maxPolarAngle = Math.PI / 2;   // can't orbit below the ground plane
    controls.touches = {
        ONE: THREE.TOUCH.ROTATE,
        TWO: THREE.TOUCH.DOLLY_ROTATE,
    };
    controls.autoRotate = true;  // slowly spins the tree until the user interacts
    controls.autoRotateSpeed = 2.0;
    controls.addEventListener("start", () => {
        controls.autoRotate = false;    // stop auto-rotating as soon as the user takes control
    });

    // prevent page scroll/pinch-zoom from hijacking touch/wheel input
    // meant for orbiting/zooming the camera
    renderer.domElement.style.touchAction = "none";
    renderer.domElement.addEventListener(
        "wheel",
        (event) => event.preventDefault(),
        { passive: false }
    );

    let currentTreeGroup = null;
    const cubeTemplateReady = loadCubeTemplate();

    // showTree
    // - loads the given target tree by id and fits the camera to it
    // - false if the id is unknown
    async function showTree(treeId) {
        const entry = TARGET_TREES.find((candidate) => candidate.id === treeId);
        if (!entry) {
            console.warn(`Unknown target tree id: "${treeId}"`);
            return false;
        }

        await cubeTemplateReady;

        if (currentTreeGroup) {
            scene.remove(currentTreeGroup);
        }

        currentTreeGroup = buildTreeGroup(entry.tree);
        // to also show the root marker (frame + front arrow) here:
        // currentTreeGroup = buildTreeGroup(entry.tree, null, { showRootMarker: true });
        scene.add(currentTreeGroup);

        const box = new THREE.Box3().setFromObject(currentTreeGroup);
        placeGroundUnderBox(ground, box);

        fitCameraToBox(camera, box);
        controls.target.copy(box.getCenter(new THREE.Vector3()));
        controls.update();

        console.log(`Showing target tree "${entry.name}".`);
        return true;
    }

    // animate
    // - render loop, driven by requestAnimationFrame
    function animate() {
        requestAnimationFrame(animate);
        controls.update();
        renderer.render(scene, camera);
    }

    animate();

    return { showTree };
}
