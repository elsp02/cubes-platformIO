// scene_test2.js - appearance test variant 2: Bloom + emissive tint.
//
// The "neon/LED" look: for correct/wrong the whole cube is tinted via
// emissive color and driven so bright that the bloom post-processing
// makes it BLEED light into the scene, like the real cubes' LEDs.
// The glow strength pulses by animating emissiveIntensity.
//
// Open via /test/index2.html (variant 1 with the outline halo stays
// at /test/). Tweak STATUS_APPEARANCE and BLOOM below.
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// post-processing: UnrealBloomPass makes every pixel brighter than
// its threshold bleed light outward (the actual "glow")
import { EffectComposer } from "three/addons/postprocessing/EffectComposer.js";
import { RenderPass } from "three/addons/postprocessing/RenderPass.js";
import { UnrealBloomPass } from "three/addons/postprocessing/UnrealBloomPass.js";
import { OutputPass } from "three/addons/postprocessing/OutputPass.js";


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

// page-relative: the html lives in /test/, the model in /test/assets/
const CUBE_MODEL_URL = "./assets/cube_model_z.glb";

// same scale as in src/scene_glb.js
const MODEL_SCALE = 25.0;

// global bloom settings.
// threshold 1.0 = only OVERBRIGHT pixels bloom (emissive intensity
// pushed past 1), so the normally lit scene stays crisp. Lowering it
// makes highlights on the ground/cube glow too.
const BLOOM = {
    strength: 1.0,   // how strong the light bleed is
    radius: 0.6,     // how far the glow spreads
    threshold: 1.0,  // minimum brightness before a pixel blooms
};

// appearance per status - THIS is what you want to tweak.
// "original" = untinted GLB materials.
// correct/wrong: emissive tint whose intensity pulses between
//   minIntensity and maxIntensity (values above ~2 start to bloom;
//   pulseSpeed in pulses per second).
// attachable: transparent blue ghost, no bloom.
const STATUS_APPEARANCE = {
    original:   null,
    correct:    { tint: 0x22bb44, minIntensity: 0.6, maxIntensity: 1.0, pulseSpeed: 0.5 },  // green
    wrong:      { tint: 0xcc2222, minIntensity: 0.6, maxIntensity: 5.0, pulseSpeed: 0.5 },  // red
    attachable: { tint: 0x3388ff, tintStrength: 0.4, opacity: 0.35 },  // transparent blue ghost
};

// button id in index2.html  ->  status name above
const BUTTON_STATUS = {
    original: "original",
    valid:    "correct",
    invalid:  "wrong",
    ghost:    "attachable",
};


// Z is the vertical axis, same convention as the real visualization
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);


// ------------------------------------------------------------
// Module state (filled by loading / status changes)
// ------------------------------------------------------------

let cubeModel = null;      // the one cube shown on this page
let pulseMaterials = [];   // tinted material clones whose intensity pulses
let activePulse = null;    // pulse params of the current status, null = none


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

// post-processing chain: normal render -> bloom -> color output
const composer = new EffectComposer(renderer);
composer.addPass(new RenderPass(scene, camera));

const bloomPass = new UnrealBloomPass(
    new THREE.Vector2(container.clientWidth || 1, container.clientHeight || 1),
    BLOOM.strength,
    BLOOM.radius,
    BLOOM.threshold
);
composer.addPass(bloomPass);

composer.addPass(new OutputPass()); // color-space correction, must be last

// resize to the CONTAINER (not the window), so the canvas follows the
// page layout; ResizeObserver also fires on layout changes
function resizeToContainer() {
    const w = container.clientWidth || 1;
    const h = container.clientHeight || 1;

    renderer.setSize(w, h, false);
    composer.setSize(w, h); // propagates to all passes incl. the bloom
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
        // slightly gray instead of pure white: a fully lit white ground
        // would cross the bloom threshold and the whole floor would glow
        color: 0xbbbbbb,
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
// Status appearance (emissive tint, glow strength via bloom)
// ------------------------------------------------------------

function applyStatus(statusName) {
    if (cubeModel === null) {
        console.warn("Cube model not loaded yet.");
        return;
    }

    const appearance = STATUS_APPEARANCE[statusName]; // null = original
    const isGhost = appearance !== null && appearance.opacity !== undefined;
    const isNeon = appearance !== null && appearance.minIntensity !== undefined;

    pulseMaterials = [];
    activePulse = isNeon
        ? {
            speed: appearance.pulseSpeed,
            minIntensity: appearance.minIntensity,
            maxIntensity: appearance.maxIntensity,
        }
        : null;

    cubeModel.traverse((object) => {
        if (!object.isMesh) {
            return;
        }

        // always start from clones of the pristine materials
        const tinted = object.userData.originalMaterials.map((material) => {
            const clone = material.clone();

            if (appearance === null) {
                return clone;
            }

            // emissive = color the surface "glows" with, independent of
            // lighting; intensities above the bloom threshold bleed light
            if (clone.emissive !== undefined) {
                clone.emissive = new THREE.Color(appearance.tint);

                if (isNeon) {
                    clone.emissiveIntensity = appearance.minIntensity;
                    pulseMaterials.push(clone); // animated in animate()
                } else {
                    clone.emissiveIntensity = appearance.tintStrength;
                }
            }

            if (isGhost) {
                clone.transparent = true;
                clone.opacity = appearance.opacity;
                clone.depthWrite = false; // avoids transparency sorting artifacts
            }

            return clone;
        });

        object.material = Array.isArray(object.material) ? tinted : tinted[0];
        object.castShadow = !isGhost; // ghost slots throw no shadows
    });
}


// ------------------------------------------------------------
// Button wiring
// ------------------------------------------------------------

for (const [buttonId, statusName] of Object.entries(BUTTON_STATUS)) {
    const button = document.getElementById(buttonId);
    if (!button) {
        console.warn(`Button #${buttonId} not found in index2.html`);
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

    // LED pulsation: emissive intensity swings sinusoidally, the bloom
    // pass turns the overbright phases into visible light bleed
    if (activePulse !== null) {
        const t = performance.now() / 1000;
        const swing = 0.5 + 0.5 * Math.sin(t * activePulse.speed * 2 * Math.PI);

        const intensity =
            activePulse.minIntensity
            + (activePulse.maxIntensity - activePulse.minIntensity) * swing;

        for (const material of pulseMaterials) {
            material.emissiveIntensity = intensity;
        }
    }

    controls.update();
    composer.render(); // full pass chain: render -> bloom -> output
}
animate();
