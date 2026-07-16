// scene_glb.js - the actual 3D view: builds the three.js scene and
// renders the evaluated tree with the exported GLB cube model.
//
// Position in the frontend:
//   main.js calls initScene() once at startup, then redrawTree(tree)
//   for every tree that ws_client.js receives. Poses come from
//   layout.js; this file handles everything visual (camera, lights,
//   model loading, status colors, nesting).
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import {
    localPoseForRoot,
    localPoseForChild,
    CUBE_SIZE
} from "./layout.js";


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

const CUBE_MODEL_URL = "/assets/cube_model_z.glb";

// Change this only if your exported cube model is not 1 x 1 x 1 units.
const MODEL_SCALE = 25.0;


// ------------------------------------------------------------
// Three.js globals (created once in initScene, reused everywhere)
// ------------------------------------------------------------

let scene;      // root of everything three.js draws
let camera;
let renderer;
let controls;   // OrbitControls (mouse rotation/zoom)
let cubeGroup;  // parent group of the whole cube construction

let cubeTemplate = null;  // loaded GLB model, cloned per cube (see loadCubeModel)
let latestTree = null;    // last received tree, kept for a redraw after the model loads


// Use Z as the vertical axis, similar to your Meshcat / NumPy logic.
// (three.js default is Y-up; this must match the math in layout.js)
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);


//-----------------------------------------------------------
// function definitions
//-----------------------------------------------------------
// add camera -
function addCamera(){
    //create a new camera with positions and angles - fov, aspect, closest visible distance from camera, farest ...
    camera = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 1000 );

    //set how far the camera will be from the 3D model - should depend on the construction size, always all cubes in scene visible
    camera.position.set(4, -6, 4);

    //where the camera should look at
    camera.lookAt(0,0,0);

    //z is vertikal -> camera also z as upward direction
    camera.up.set(0, 0, 1);
}

//add renderer
function addRenderer(){
    //instantiate a new renderer and set its size
    // parameters: alpha: transparent background, antialias: Kantenglättung
    //https://threejs.org/docs/#Renderer
    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);

    // match the render resolution to the screen's physical pixel density
    // (capped at 2: sharper on high-DPI displays without rendering 3-4x
    // the pixels on phones - purely a quality/performance trade-off)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Enable shadow rendering
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    //Add the renderert o the DOM - complete screen and not within a container
    document.body.appendChild(renderer.domElement);
    // if scene should be in a container: document.getElementById("container").appendChild(renderer.domElement)

}

// add light
function addLights() {
    //illuminates every surface equally from all directions, providing a flat base brightness
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.7); //color, intensity
    scene.add(ambientLight);

    //simulates rays from an infinitely distant source (like the sun)
    // position = direction the rays come FROM; above and diagonally in
    // front of the tower, so every visible face gets some light and the
    // shadow falls behind the construction
    const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
    topLight.position.set(4, -5, 8);
    scene.add(topLight);
    topLight.castShadow = true;
}

// add axes (x=red, y=green, z=blue) and a ground grid for orientation
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
    //target is point the camera orbits around
    controls.target.set(0,0,0);
    //update() applies the target and internal control state
    controls.update();

}

//window resize handling for when the browser window changes size, the camera aspect ratio must be updated. Otherwise the image becomes stretched.
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
}

// render loop: requestAnimationFrame schedules this function again for
// the next display frame (~60x per second), so the scene stays
// interactive (OrbitControls) even when no new tree arrives
function animate() {
    requestAnimationFrame(animate);

    controls.update();
    //scene rendering
    renderer.render(scene, camera);
}

//------------------------------------------------------------
// Scene initialization - main function, called once from main.js
//------------------------------------------------------------
export function initScene(){
//create a Threejs Scene
    scene = new THREE.Scene();

    addCamera();
    addRenderer();
    addControls();

//add helpers
    addLights();
    addHelpers();
    addGround();

// cubeGroup = contains the complete cube construction
// (redrawTree only ever clears/fills this group, never the whole scene,
// so lights/camera/helpers survive every redraw)
    cubeGroup = new THREE.Group();
    cubeGroup.name = "cubeGroup";
    scene.add(cubeGroup);

    loadCubeModel();

//Add a listener to the window, so we can resize the window and the camera
    window.addEventListener("resize", onWindowResize);

    animate();

}

// large white plane just below the cubes that receives their shadows
function addGround() {
    const groundSize = 1000;

    const groundGeometry = new THREE.PlaneGeometry(
        groundSize,
        groundSize
    );

    const groundMaterial = new THREE.MeshStandardMaterial({
        color: 0xffffff,
        roughness: 0.8,   // mostly matte surface
        metalness: 0.0,
    });

    const ground = new THREE.Mesh(groundGeometry, groundMaterial);

    // top of the ground exactly at the bottom face of the root cube
    ground.position.set(0, 0, -CUBE_SIZE / 2);

    ground.receiveShadow = true;

    scene.add(ground);
}


// ------------------------------------------------------------
// loads a template mesh for the cube
//
// Loading the GLB file is asynchronous (it is an HTTP request), so the
// template is null until the callback below fires. Every drawn cube is
// a CLONE of this template - the file is fetched exactly once.
// ------------------------------------------------------------

function loadCubeModel() {
    const loader = new GLTFLoader();

    loader.load(
        CUBE_MODEL_URL,

        // success callback, runs when the file has arrived
        function (gltf)  {
            //sets glb file as cubeTemplate model
            cubeTemplate = gltf.scene;

            // enable shadows on every mesh inside the model
            // (traverse visits the model's whole object hierarchy)
            cubeTemplate.traverse((object) => {
                if (object.isMesh) {
                    object.castShadow = true;
                    object.receiveShadow = true;
                }
            });

            console.log("Cube model loaded:", CUBE_MODEL_URL);

            // If a tree arrived before the model finished loading, draw it now.
            if (latestTree !== null) {
                redrawTree(latestTree);
            }
        },
        undefined,   // progress callback, not needed

        // error callback
        function (error) {
            console.error("Could not load cube model:", error);
        }
    );
}


// ------------------------------------------------------------
// evaluated-tree node view + status appearance
// ------------------------------------------------------------

/*
 * Normalizes one node so the renderer works with both formats:
 *   evaluated tree (new): node_id, status, error_mask, expected_orientation
 *   raw detection tree (old): id, no status
 * Ghost = empty target slot (attachable): no physical cube, so no own
 * orientation -> the expected one is used.
 * (?? is the "nullish coalescing" operator: use the right side only
 * when the left side is null or undefined)
 */
function nodeView(node) {
    const id = node.node_id ?? node.id ?? null;

    return {
        id: id,
        isGhost: id === null,
        status: node.status ?? "correct",
        errorMask: node.error_mask ?? 0,
        orientation: node.orientation ?? node.expected_orientation ?? 0,
        port: node.port,
        children: node.children ?? [],
    };
}

// mirror of the physical LEDs plus ghost slots; "blocked" is not listed
// because blocked slots are not rendered at all
const STATUS_APPEARANCE = {
    correct:    { tint: 0x22bb44, tintStrength: 0.25, opacity: 1.0 },   // green
    wrong:      { tint: 0xcc2222, tintStrength: 0.5,  opacity: 1.0 },   // red
    unexpected: { tint: 0xcc2222, tintStrength: 0.5,  opacity: 1.0 },   // red
    attachable: { tint: 0x3388ff, tintStrength: 0.4,  opacity: 0.35 },  // transparent blue ghost
};

// tints the cloned model per status; materials must be cloned too,
// because clone(true) on an Object3D copies meshes but SHARES their
// materials - without cloning them, coloring one cube would recolor
// every cube in the scene
function applyStatusAppearance(visualModel, view) {
    const appearance = STATUS_APPEARANCE[view.status];

    if (!appearance) {
        return;  // unknown status: leave the model in its original look
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

        const tinted = materials.map((material) => {
            const clone = material.clone();

            // emissive = color the surface "glows" with, independent of
            // lighting - a reliable way to tint without repainting textures
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

        if (appearance.opacity < 1.0) {
            object.castShadow = false; // ghost slots should not throw shadows
        }
    });
}


// ------------------------------------------------------------
// creates one cube instance
// ------------------------------------------------------------

function createCubeObject(view) {
    /*
     * This group represents one logical cube node.
     *
     * The GLB model is added as a visual child.
     * Other cube nodes can then be added as children of this group.
     */

    const cubeObject = new THREE.Group();

    // readable name + userData: not used for rendering, but they make
    // debugging in the browser console much easier (scene.getObjectByName)
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


    if (cubeTemplate === null) {
        throw new Error("Cube model is not loaded yet.");
    }

    //uses the template cube defined in loadCubeModel as the visual model
    // clone(true) = deep clone including all child meshes
    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);

    applyStatusAppearance(visualModel, view);

    cubeObject.add(visualModel);

    return cubeObject;
}


// ------------------------------------------------------------
// Nested tree rendering
// ------------------------------------------------------------

// removes all cubes from the scene (used when the server connection is lost,
// so the display never shows stale data)
export function clearTree() {
    latestTree = null;
    cubeGroup.clear();
}


// full redraw: throw away all cube objects and rebuild them from the
// tree (simple and always correct; fine at this scale of a few cubes)
export function redrawTree(rootNode) {
    latestTree = rootNode;

    if (cubeTemplate === null) {
        // GLB still loading; loadCubeModel's callback redraws latestTree later
        console.warn("Cube model not loaded yet. Tree will be drawn after loading.");
        return;
    }

    cubeGroup.clear();

    addCubeRecursive(rootNode, cubeGroup, true);
}


// walks the tree depth-first and mirrors it as nested three.js groups:
// each cube object is added as a CHILD of its parent's object, so the
// local poses from layout.js are automatically stacked up the chain
function addCubeRecursive(node, parentObject, isRoot) {
    const view = nodeView(node);

    // blocked slots (and everything below them) are not buildable yet -> hidden
    if (view.status === "blocked") {
        return;
    }

    const cubeObject = createCubeObject(view);

    const pose = isRoot
        ? localPoseForRoot(view)
        : localPoseForChild(view);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject); //this is where nesting and child parent relationship happens

    for (const child of view.children) {
        addCubeRecursive(child, cubeObject, false);
    }
}
