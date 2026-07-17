// scene_test.js - standalone appearance test page.
//
// Shows ONE cube (the exported GLB model) and lets you switch its
// status appearance with the buttons above the view. This page is
// completely independent of the websocket pipeline; it only exists to
// try out how the cube looks per status (original / correct / wrong /
// ghost). Tweak STATUS_APPEARANCE below, then copy the values you like
// into src/scene_glb.js.
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// post-processing: OutlinePass draws a soft glowing halo along the
// cube's visible silhouette (with built-in pulsation); the composer
// chains it behind the normal render
import { EffectComposer } from "three/addons/postprocessing/EffectComposer.js";
import { RenderPass } from "three/addons/postprocessing/RenderPass.js";
import { OutlinePass } from "three/addons/postprocessing/OutlinePass.js";
import { OutputPass } from "three/addons/postprocessing/OutputPass.js";


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

// page-relative: the html lives in /test/, the model in /test/assets/
const CUBE_MODEL_URL = "./assets/cube_model_z.glb";

// same scale as in src/scene_glb.js
const MODEL_SCALE = 25.0;

// appearance per status - THIS is what you want to tweak.
// "original" = untinted GLB materials.
// correct/wrong: body stays original, a glowing halo pulses around
//   the cube's silhouette (edgeStrength = brightness, edgeGlow = how
//   far the glow bleeds, edgeThickness in px, pulsePeriod in seconds
//   per pulse, 0 = steady glow without pulsing).
// attachable: transparent blue ghost, as in src/scene_glb.js.
const STATUS_APPEARANCE = {
    original:   null,
    correct:    { edgeColor: 0x117E2F, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 4 },  // green
    wrong:      { edgeColor: 0xcc2222, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 2 },  // red
    attachable: { tint: 0x3388ff, tintStrength: 0.4, opacity: 0.35 },  // transparent blue ghost
};

// button id in index.html  ->  status name above
const BUTTON_STATUS = {
    original: "original",
    valid:    "correct",
    invalid:  "wrong",
    ghost:    "attachable",
};


// Z is the vertical axis, same convention as the real visualization
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);


// ------------------------------------------------------------
// Scene setup (container-sized, not fullscreen)
// ------------------------------------------------------------

const container = document.getElementById("würfel");
if (!container) {
    throw new Error("#würfel wurde nicht gefunden.");
}

const scene = new THREE.Scene();

// explicit background matching the page color: the composer renders
// into a texture, where a transparent canvas is unreliable
scene.background = new THREE.Color(0xfbfaf2);

const camera = new THREE.PerspectiveCamera(60, 1, 0.1, 1000);
camera.position.set(4, -6, 4);
camera.up.set(0, 0, 1);
camera.lookAt(0, 0, 0);

const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
container.appendChild(renderer.domElement);

// post-processing chain: normal render -> outline glow -> color output
const composer = new EffectComposer(renderer);
composer.addPass(new RenderPass(scene, camera));

const outlinePass = new OutlinePass(
    new THREE.Vector2(container.clientWidth || 1, container.clientHeight || 1),
    scene,
    camera
);
outlinePass.selectedObjects = []; // nothing glows until a status sets it
composer.addPass(outlinePass);

composer.addPass(new OutputPass()); // color-space correction, must be last

// resize to the CONTAINER (not the window), so the canvas follows the
// page layout; ResizeObserver also fires on layout changes
function resizeToContainer() {
    const w = container.clientWidth || 1;
    const h = container.clientHeight || 1;

    renderer.setSize(w, h, false);
    composer.setSize(w, h); // propagates to all passes incl. the outline
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
}
resizeToContainer();

const ro = new ResizeObserver(resizeToContainer);
ro.observe(container);


// ------------------------------------------------------------
// Lights + ground (same look as the real scene, so the appearance
// test is representative)
// ------------------------------------------------------------

const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
scene.add(ambientLight);

const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
topLight.position.set(4, -5, 8);
topLight.castShadow = true;
scene.add(topLight);

const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(1000, 1000),
    new THREE.MeshStandardMaterial({
        color: 0x757575,
        roughness: 0.8,
        metalness: 0.0,
    })
);
ground.receiveShadow = true;
scene.add(ground); // moved under the cube once the model is loaded


// ------------------------------------------------------------
// OrbitControls
// ------------------------------------------------------------

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = false;

// mobile touch: one finger rotates, two fingers zoom
controls.touches = {
    ONE: THREE.TOUCH.ROTATE,
    TWO: THREE.TOUCH.DOLLY_ROTATE,
};

// stop the browser from scrolling/zooming the page while interacting
renderer.domElement.style.touchAction = "none";
renderer.domElement.addEventListener("wheel", (e) => e.preventDefault(), { passive: false });


// ------------------------------------------------------------
// Model loading
// ------------------------------------------------------------

let cubeModel = null; // the one cube shown on this page

const loader = new GLTFLoader();
loader.load(
    CUBE_MODEL_URL,

    (gltf) => {
        cubeModel = gltf.scene;
        cubeModel.scale.setScalar(MODEL_SCALE);

        cubeModel.traverse((object) => {
            if (!object.isMesh) {
                return;
            }

            object.castShadow = true;
            object.receiveShadow = true;

            // remember the pristine materials so every status change can
            // start from the original look (otherwise tints would stack)
            const materials = Array.isArray(object.material)
                ? object.material
                : [object.material];
            object.userData.originalMaterials = materials;
        });

        scene.add(cubeModel);

        fitCameraToCube();
        applyStatus("original");

        console.log("Cube model loaded:", CUBE_MODEL_URL);
    },

    undefined, // progress callback, not needed

    (error) => console.error("Could not load cube model:", error)
);

// point the controls at the cube's center and put the camera at a
// distance where the whole cube is comfortably visible
function fitCameraToCube() {
    const box = new THREE.Box3().setFromObject(cubeModel);
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    // ground directly under the cube
    ground.position.z = box.min.z - 0.001;

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = THREE.MathUtils.degToRad(camera.fov);
    let dist = (maxDim / 2) / Math.tan(fov / 2);
    dist *= 1.6; // a bit of air around the cube

    // diagonally from the front, slightly above (Z-up)
    const dir = new THREE.Vector3(1, -1.2, 0.8).normalize();
    camera.position.copy(center).addScaledVector(dir, dist);

    camera.near = dist / 100;
    camera.far = dist * 100;
    camera.updateProjectionMatrix();

    controls.target.copy(center);
    controls.minDistance = dist * 0.3;
    controls.maxDistance = dist * 3.0;
    controls.update();
}


// ------------------------------------------------------------
// Status appearance (same tinting technique as scene_glb.js)
// ------------------------------------------------------------

function applyStatus(statusName) {
    if (cubeModel === null) {
        console.warn("Cube model not loaded yet.");
        return;
    }

    const appearance = STATUS_APPEARANCE[statusName]; // null = original

    // body tint only applies to the ghost; correct/wrong/original all
    // keep the untinted GLB materials (correct/wrong glow via outline)
    const tintBody = appearance !== null && appearance.tint !== undefined;
    const isGhost = tintBody && appearance.opacity < 1.0;

    cubeModel.traverse((object) => {
        if (!object.isMesh) {
            return;
        }

        // always start from clones of the pristine materials
        const tinted = object.userData.originalMaterials.map((material) => {
            const clone = material.clone();

            if (!tintBody) {
                return clone;
            }

            // emissive = color the surface "glows" with, independent of
            // lighting - tints without repainting the textures
            if (clone.emissive !== undefined) {
                clone.emissive = new THREE.Color(appearance.tint);
                clone.emissiveIntensity = appearance.tintStrength;
            }

            if (appearance.opacity < 1.0) {
                clone.transparent = true;
                clone.opacity = appearance.opacity;
                clone.depthWrite = false; // avoids transparency sorting artifacts
            }

            return clone;
        });

        object.material = Array.isArray(object.material) ? tinted : tinted[0];
        object.castShadow = !isGhost; // ghost slots throw no shadows
    });

    // glowing halo: active only for statuses with edgeColor
    if (appearance !== null && appearance.edgeColor !== undefined) {
        outlinePass.selectedObjects = [cubeModel];

        // visible = silhouette parts facing the camera,
        // hidden = parts occluded by the cube itself
        outlinePass.visibleEdgeColor.set(appearance.edgeColor);
        outlinePass.hiddenEdgeColor.set(appearance.edgeColor);

        outlinePass.edgeStrength = appearance.edgeStrength;
        outlinePass.edgeGlow = appearance.edgeGlow;
        outlinePass.edgeThickness = appearance.edgeThickness;
        outlinePass.pulsePeriod = appearance.pulsePeriod;
    } else {
        outlinePass.selectedObjects = [];
    }
}


// ------------------------------------------------------------
// Button wiring
// ------------------------------------------------------------

for (const [buttonId, statusName] of Object.entries(BUTTON_STATUS)) {
    const button = document.getElementById(buttonId);
    if (!button) {
        console.warn(`Button #${buttonId} not found in index.html`);
        continue;
    }

    button.addEventListener("click", () => {
        applyStatus(statusName);

        // highlight the active button
        document.querySelectorAll(".button-section .button")
            .forEach((b) => b.classList.toggle("active", b === button));
    });
}


// ------------------------------------------------------------
// Render loop
// ------------------------------------------------------------

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    composer.render(); // full pass chain: render -> outline glow -> output
}
animate();
