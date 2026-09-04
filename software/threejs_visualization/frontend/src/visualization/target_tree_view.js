// target_tree_view.js - shared interactive target-tree renderer.
//
// Both the dashboard preview and bauen_target.html use this module.
// Keeping the scene, camera, controls and tree construction here makes
// the selected target tree look exactly the same in both places; only
// the size of the supplied container differs.

import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import { loadCubeTemplate, buildTreeGroup, fitCameraToBox } from "./tree_builder.js";
import { addSceneEnvironment, placeGroundUnderBox } from "./scene_environment.js";
import { TARGET_TREES } from "../target-tree/index.js";

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

    function resizeToContainer() {
        const width = container.clientWidth || 1;
        const height = container.clientHeight || 1;

        renderer.setSize(width, height, false);
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
    }

    resizeToContainer();

    const resizeObserver = new ResizeObserver(resizeToContainer);
    resizeObserver.observe(container);

    const { ground } = addSceneEnvironment(scene);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.enablePan = false;
    controls.maxPolarAngle = Math.PI / 2;
    controls.touches = {
        ONE: THREE.TOUCH.ROTATE,
        TWO: THREE.TOUCH.DOLLY_ROTATE,
    };
    controls.autoRotate = true;
    controls.autoRotateSpeed = 2.0;
    controls.addEventListener("start", () => {
        controls.autoRotate = false;
    });

    renderer.domElement.style.touchAction = "none";
    renderer.domElement.addEventListener(
        "wheel",
        (event) => event.preventDefault(),
        { passive: false }
    );

    let currentTreeGroup = null;
    const cubeTemplateReady = loadCubeTemplate();

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
        scene.add(currentTreeGroup);

        const box = new THREE.Box3().setFromObject(currentTreeGroup);
        placeGroundUnderBox(ground, box);

        fitCameraToBox(camera, box);
        controls.target.copy(box.getCenter(new THREE.Vector3()));
        controls.update();

        console.log(`Showing target tree "${entry.name}".`);
        return true;
    }

    function animate() {
        requestAnimationFrame(animate);
        controls.update();
        renderer.render(scene, camera);
    }

    animate();

    return { showTree };
}
