// comparison_view.js - the left-hand "target reference" view on
// bauen_vergleich.html.
//
// Fed the SAME evaluated tree bauen.js also passes to scene_glb.js for
// the live view, but rendered differently:
//   - nothing is hidden (skipBlocked: false), so the full target
//     structure is visible from the very first message, ghosts included
//   - only correct/wrong get a glow halo (same OutlinePass mechanism as
//     the live view); everything else (ghost, blocked, ...) stays the
//     plain, untinted cube model - like the preview.
//
// Independent scene/camera/renderer/controls/composer, same pattern as
// target_tree_view.js (own container, own OrbitControls with
// auto-rotate) - this never touches scene_glb.js's state, so the live
// view on the right keeps working exactly as before.

import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { EffectComposer } from "three/addons/postprocessing/EffectComposer.js";
import { RenderPass } from "three/addons/postprocessing/RenderPass.js";
import { OutlinePass } from "three/addons/postprocessing/OutlinePass.js";
import { OutputPass } from "three/addons/postprocessing/OutputPass.js";

import {
    loadCubeTemplate,
    isCubeTemplateLoaded,
    buildTreeGroup,
    fitCameraToBox,
} from "./tree_builder.js";
import { addSceneEnvironment, placeGroundUnderBox } from "./scene_environment.js";

// same colors/timing as scene_glb.js's STATUS_APPEARANCE - kept in sync
// manually since the two views are independent rendering pipelines
const HALO_APPEARANCE = {
    correct:    { edgeColor: 0x117E2F, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 4 },  // green
    wrong:      { edgeColor: 0xcc2222, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 2 },  // red
    unexpected: { edgeColor: 0xcc2222, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 2 },  // red
};

export function createComparisonView(container) {
    if (!container) {
        throw new Error("Container für die Vergleichsansicht wurde nicht gefunden.");
    }

    const scene = new THREE.Scene();

    const camera = new THREE.PerspectiveCamera(60, 1, 0.1, 1000);
    camera.up.set(0, 0, 1);

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild(renderer.domElement);

    function viewSize() {
        return {
            width: container.clientWidth || 1,
            height: container.clientHeight || 1,
        };
    }

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

    // post-processing: normal render -> green outline -> red outline -> output
    // (same chain as scene_glb.js's addComposer, own instance here)
    const composer = new EffectComposer(renderer);
    composer.addPass(new RenderPass(scene, camera));

    function makeOutlinePass(appearance) {
        const { width, height } = viewSize();
        const pass = new OutlinePass(new THREE.Vector2(width, height), scene, camera);

        pass.visibleEdgeColor.set(appearance.edgeColor);
        pass.hiddenEdgeColor.set(appearance.edgeColor);
        pass.edgeStrength = appearance.edgeStrength;
        pass.edgeGlow = appearance.edgeGlow;
        pass.edgeThickness = appearance.edgeThickness;
        pass.pulsePeriod = appearance.pulsePeriod;
        pass.selectedObjects = [];

        return pass;
    }

    const outlineCorrect = makeOutlinePass(HALO_APPEARANCE.correct);
    composer.addPass(outlineCorrect);

    const outlineWrong = makeOutlinePass(HALO_APPEARANCE.wrong);
    composer.addPass(outlineWrong);

    composer.addPass(new OutputPass()); // color-space correction, must be last

    function resizeToContainer() {
        const { width, height } = viewSize();

        renderer.setSize(width, height, false);
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
        composer.setSize(width, height);
    }

    resizeToContainer();
    const resizeObserver = new ResizeObserver(resizeToContainer);
    resizeObserver.observe(container);

    const cubeGroup = new THREE.Group();
    cubeGroup.name = "comparisonCubeGroup";
    scene.add(cubeGroup);

    let correctSelection = [];
    let wrongSelection = [];
    let latestTree = null;    // last received tree, redrawn once the model loads
    let cameraFitted = false; // the target structure's size never changes, so this fits once

    // decorate hook: only correct/wrong get a glow, everything else
    // (ghost, blocked, ...) stays the plain, untinted cube model
    function decorateCube(cubeObject, view) {
        const appearance = HALO_APPEARANCE[view.status];
        if (appearance !== undefined) {
            const selection = view.status === "correct" ? correctSelection : wrongSelection;
            selection.push(cubeObject.children[0]);
        }
    }

    function redrawTree(rootNode) {
        latestTree = rootNode;

        if (!isCubeTemplateLoaded()) {
            // GLB still loading; the loadCubeTemplate().then() below redraws latestTree later
            return;
        }

        cubeGroup.clear();
        correctSelection = [];
        wrongSelection = [];

        cubeGroup.add(buildTreeGroup(rootNode, decorateCube, { skipBlocked: false }));

        outlineCorrect.selectedObjects = correctSelection;
        outlineWrong.selectedObjects = wrongSelection;

        const box = new THREE.Box3().setFromObject(cubeGroup);
        placeGroundUnderBox(ground, box);

        if (!cameraFitted) {
            fitCameraToBox(camera, box);
            controls.target.copy(box.getCenter(new THREE.Vector3()));
            controls.update();
            cameraFitted = true;
        }
    }

    loadCubeTemplate()
        .then(() => {
            if (latestTree !== null) {
                redrawTree(latestTree);
            }
        })
        .catch((error) => console.error("Could not load cube model:", error));

    function animate() {
        requestAnimationFrame(animate);
        controls.update();
        composer.render();
    }

    animate();

    // removes all cubes from the scene (used when the server connection
    // is lost, so the display never shows a stale build state)
    function clearTree() {
        latestTree = null;
        cameraFitted = false; // next tree starts a fresh session -> refit the camera
        cubeGroup.clear();

        correctSelection = [];
        wrongSelection = [];
        outlineCorrect.selectedObjects = [];
        outlineWrong.selectedObjects = [];
    }

    return { redrawTree, clearTree };
}
