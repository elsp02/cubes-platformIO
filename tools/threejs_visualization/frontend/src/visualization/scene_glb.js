// scene_glb.js - the actual 3D view: builds the three.js scene and
// renders the evaluated tree with the exported GLB cube model.
//
// Position in the frontend:
//   bauen.js calls initScene() once at startup, then redrawTree(tree)
//   for every tree that ws_client.js receives. The tree itself is built
//   by the shared tree_builder.js (same code as thumbnails/preview);
//   this file adds everything only the live view needs: camera, lights,
//   ground, controls and the per-cube status colors.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// post-processing: OutlinePass draws a soft glowing halo along the
// cubes' visible silhouette (with built-in pulsation); the composer
// chains it behind the normal render (same setup as test/src/scene_test.js)
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


// ------------------------------------------------------------
// Three.js globals (created once in initScene, reused everywhere)
// ------------------------------------------------------------

let scene;      // root of everything three.js draws
let camera;
let renderer;
let controls;   // OrbitControls (mouse rotation/zoom)
let cubeGroup;  // parent group of the whole cube construction
let ground;     // shared shadow plane, repositioned under every drawn tree

let composer;        // post-processing chain: render -> outlines -> output
let outlineCorrect;  // green pulsing halo around correct cubes
let outlineWrong;    // red pulsing halo around wrong/unexpected cubes

// models collected per redraw, then assigned to the outline passes
// (one pass can only have ONE color/pulse, so one list per status group)
let correctSelection = [];
let wrongSelection = [];

let latestTree = null;    // last received tree, kept for a redraw after the model loads
let cameraFitted = false; // fitCameraToBox only on the FIRST tree, afterwards the user's OrbitControls position stays untouched

// container element the scene renders into; null = legacy fullscreen
// mode (renderer on <body>, sized to the window - used by index2.html)
let viewContainer = null;

// current drawing size: the container's inner size, or the window size
// in fullscreen mode ("|| 1" avoids a zero-size renderer/aspect while
// the container is still laying out)
function viewSize() {
    if (viewContainer) {
        return {
            width: viewContainer.clientWidth || 1,
            height: viewContainer.clientHeight || 1,
        };
    }
    return { width: window.innerWidth, height: window.innerHeight };
}


//-----------------------------------------------------------
// function definitions
//-----------------------------------------------------------
// add camera -
function addCamera(){
    const { width, height } = viewSize();

    //create a new camera with positions and angles - fov, aspect, closest visible distance from camera, farest ...
    camera = new THREE.PerspectiveCamera(60, width/height, 0.1, 1000 );

    //z is vertikal -> camera also z as upward direction
    camera.up.set(0, 0, 1);

    // position/near/far/lookAt are set by fitCameraToBox() once the first
    // tree is drawn (see redrawTree) - same pattern as tree_preview.js
}

//add renderer
function addRenderer(){
    //instantiate a new renderer and set its size
    // parameters: alpha: transparent background, antialias: Kantenglättung
    //https://threejs.org/docs/#Renderer
    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });

    const { width, height } = viewSize();
    renderer.setSize(width, height);

    // match the render resolution to the screen's physical pixel density
    // (capped at 2: sharper on high-DPI displays without rendering 3-4x
    // the pixels on phones - purely a quality/performance trade-off)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Enable shadow rendering
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    //Add the renderer to the DOM: into the given container (bauen.html),
    //or directly onto <body> in legacy fullscreen mode (index2.html)
    (viewContainer ?? document.body).appendChild(renderer.domElement);

}

// post-processing chain: normal render -> green outlines -> red
// outlines -> color output. scene_test.js shows ONE cube and re-uses a
// single OutlinePass; here many cubes with different statuses are
// visible at once, and one pass has only one color/pulse - so there is
// one pass per status group, each with its own selection list.
function addComposer() {
    const { width, height } = viewSize();
    const size = new THREE.Vector2(width, height);

    composer = new EffectComposer(renderer);
    composer.addPass(new RenderPass(scene, camera));

    outlineCorrect = makeOutlinePass(size, STATUS_APPEARANCE.correct);
    composer.addPass(outlineCorrect);

    outlineWrong = makeOutlinePass(size, STATUS_APPEARANCE.wrong);
    composer.addPass(outlineWrong);

    composer.addPass(new OutputPass()); // color-space correction, must be last
}

// one configured OutlinePass; edge parameters come from STATUS_APPEARANCE
function makeOutlinePass(size, appearance) {
    const pass = new OutlinePass(size, scene, camera);

    // visible = silhouette parts facing the camera,
    // hidden = parts occluded by other cubes - same color for both
    pass.visibleEdgeColor.set(appearance.edgeColor);
    pass.hiddenEdgeColor.set(appearance.edgeColor);

    pass.edgeStrength = appearance.edgeStrength;
    pass.edgeGlow = appearance.edgeGlow;
    pass.edgeThickness = appearance.edgeThickness;
    pass.pulsePeriod = appearance.pulsePeriod;

    pass.selectedObjects = []; // nothing glows until a tree is drawn

    return pass;
}

// add axes (x=red, y=green, z=blue) and a ground grid for orientation
// (debug only - not called in the normal scene, so the live view looks
// exactly like thumbnails and preview)
function addHelpers() {
    const axes = new THREE.AxesHelper(2);
    scene.add(axes);

    const grid = new THREE.GridHelper(10, 10);
    grid.rotation.x = Math.PI / 2;  // GridHelper is XZ by default, rotate into the XY plane (Z-up)
    scene.add(grid);
}

//OrbitControls allow mouse / touch interaction
// touchscreen: One finger usually rotates, two fingers zoom/pan.
function addControls(){
    controls = new OrbitControls(camera, renderer.domElement);
    // Kamera nie unter die Bodenebene kippen lassen (Z-up: PI/2 = horizontal)
    controls.maxPolarAngle = Math.PI / 2;
    //target is point the camera orbits around
    controls.target.set(0,0,0);
    //update() applies the target and internal control state
    controls.update();

}

//resize handling for when the container / browser window changes size,
//the camera aspect ratio must be updated. Otherwise the image becomes stretched.
function onResize() {
    const { width, height } = viewSize();

    camera.aspect = width / height;
    camera.updateProjectionMatrix();

    renderer.setSize(width, height);
    composer.setSize(width, height); // propagates to all passes incl. the outlines
}

// render loop: requestAnimationFrame schedules this function again for
// the next display frame (~60x per second), so the scene stays
// interactive (OrbitControls) even when no new tree arrives
function animate() {
    requestAnimationFrame(animate);

    controls.update();
    //scene rendering: full pass chain render -> outline glow -> output
    composer.render();
}

//------------------------------------------------------------
// Scene initialization - main function, called once per page.
// container: element to render into (e.g. #main-tree-canvas on
// bauen.html); without it the scene fills the whole window (index2.html)
//------------------------------------------------------------
export function initScene(container = null){
    viewContainer = container;

//create a Threejs Scene
    scene = new THREE.Scene();

    addCamera();
    addRenderer();
    addControls();
    addComposer();

// shared environment (background, lights, shadow ground) - identical
// to tree_thumbnail.js and tree_preview.js. The composer renders into
// a texture, so the explicit background color is also what keeps the
// canvas from being unreliably transparent.
    ({ ground } = addSceneEnvironment(scene));

// cubeGroup = contains the complete cube construction
// (redrawTree only ever clears/fills this group, never the whole scene,
// so lights/camera/helpers survive every redraw)
    cubeGroup = new THREE.Group();
    cubeGroup.name = "cubeGroup";
    scene.add(cubeGroup);

// shared GLB loading from tree_builder.js; if a tree arrived before the
// model finished loading, draw it now
    loadCubeTemplate()
        .then(() => {
            console.log("Cube model loaded.");
            if (latestTree !== null) {
                redrawTree(latestTree);
            }
        })
        .catch((error) => console.error("Could not load cube model:", error));

//keep renderer and camera in sync with the drawing size: the container
//is watched directly (same pattern as tree_preview.js), fullscreen mode
//keeps the window listener
    if (viewContainer) {
        new ResizeObserver(onResize).observe(viewContainer);
    } else {
        window.addEventListener("resize", onResize);
    }

    animate();

}

// ------------------------------------------------------------
// status appearance (live view only - thumbnails/preview stay untinted)
// ------------------------------------------------------------

// mirror of the physical LEDs plus ghost slots; "blocked" is not listed
// because blocked slots are not rendered at all (tree_builder skips them).
// correct/wrong/unexpected: body stays original, a glowing halo pulses
//   around the cube's silhouette (edgeStrength = brightness, edgeGlow =
//   how far the glow bleeds, edgeThickness in px, pulsePeriod in
//   seconds per pulse) - values tuned in test/src/scene_test.js.
// attachable: ghost slot, just semi-transparent, no coloring.
const STATUS_APPEARANCE = {
    correct:    { edgeColor: 0x117E2F, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 4 },  // green
    wrong:      { edgeColor: 0xcc2222, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 2 },  // red
    unexpected: { edgeColor: 0xcc2222, edgeStrength: 10, edgeGlow: 3.0, edgeThickness: 10, pulsePeriod: 2 },  // red
    attachable: { opacity: 0.8 },
};

// makes ghost slots semi-transparent; materials must be cloned,
// because clone(true) on an Object3D copies meshes but SHARES their
// materials - without cloning them, fading one cube would fade
// every cube in the scene
function applyStatusAppearance(visualModel, view) {
    const appearance = STATUS_APPEARANCE[view.status];

    // only ghost slots change the cube body itself
    if (!appearance || appearance.opacity === undefined || appearance.opacity >= 1.0) {
        return;
    }

    visualModel.traverse((object) => {
        if (!object.isMesh) {
            return;
        }

        // a mesh can have one material or an array of them; treat both
        // the same by always working on an array
        const materials = Array.isArray(object.material)
            ? object.material
            : [object.material];

        const faded = materials.map((material) => {
            const clone = material.clone();

            clone.transparent = true;
            clone.opacity = appearance.opacity;
            clone.depthWrite = false; // avoids transparency sorting artifacts

            return clone;
        });

        object.material = Array.isArray(object.material) ? faded : faded[0];

        object.castShadow = false; // ghost slots should not throw shadows
    });
}

// decorate hook for tree_builder: everything only the live view needs
// per cube - a readable name + userData for debugging in the browser
// console (scene.getObjectByName), ghost transparency and the halo
function decorateCube(cubeObject, view) {
    cubeObject.name = view.isGhost
        ? (view.port === null || view.port === undefined
            ? "slot_root"
            : `slot_port_${view.port}`)
        : `cube_${view.id.toString(16).toUpperCase()}`;
    cubeObject.userData.cubeId = view.id;
    cubeObject.userData.orientation = view.orientation;
    cubeObject.userData.port = view.port;
    cubeObject.userData.status = view.status;
    cubeObject.userData.errorMask = view.errorMask;

    applyStatusAppearance(cubeObject, view);

    // statuses with a halo color go into the matching outline pass.
    // children[0] is the cube's GLB model - at this point it is the
    // ONLY child (child cubes are attached after decorate), and taking
    // the whole group would make the entire subtree glow along
    const appearance = STATUS_APPEARANCE[view.status];
    if (appearance !== undefined && appearance.edgeColor !== undefined) {
        const selection = view.status === "correct"
            ? correctSelection
            : wrongSelection;
        selection.push(cubeObject.children[0]);
    }
}


// ------------------------------------------------------------
// Tree rendering
// ------------------------------------------------------------

// removes all cubes from the scene (used when the server connection is lost,
// so the display never shows stale data)
export function clearTree() {
    latestTree = null;
    cameraFitted = false; // next tree starts a fresh session -> refit the camera
    cubeGroup.clear();

    correctSelection = [];
    wrongSelection = [];
    outlineCorrect.selectedObjects = [];
    outlineWrong.selectedObjects = [];
}


// full redraw: throw away all cube objects and rebuild them from the
// tree (simple and always correct; fine at this scale of a few cubes)
export function redrawTree(rootNode) {
    latestTree = rootNode; //von hier wird der evaluated tree zum visualisieren gelesen

    if (!isCubeTemplateLoaded()) {
        // GLB still loading; the loadCubeTemplate().then() in initScene redraws latestTree later
        console.warn("Cube model not loaded yet. Tree will be drawn after loading.");
        return { correctCount: 0 };
    }

    cubeGroup.clear();

    // decorateCube fills these while the tree is built
    correctSelection = [];
    wrongSelection = [];

    cubeGroup.add(buildTreeGroup(rootNode, decorateCube));

    outlineCorrect.selectedObjects = correctSelection;
    outlineWrong.selectedObjects = wrongSelection;

    // shadow plane exactly under the current construction (same helper
    // as thumbnails/preview, so the ground behaves identically everywhere)
    const box = new THREE.Box3().setFromObject(cubeGroup);
    placeGroundUnderBox(ground, box);

    if (!cameraFitted) {
        fitCameraToBox(camera, box);
        controls.target.copy(box.getCenter(new THREE.Vector3()));
        controls.update();
        cameraFitted = true;
    }

    return { correctCount: correctSelection.length };
}
