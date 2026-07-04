import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import {
    localPoseForRoot,
    localPoseForChild,
} from "./layout.js";


// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

const CUBE_MODEL_URL = "/assets/cube_model.glb";

// Change this only if your exported cube model is not 1 x 1 x 1 units.
const MODEL_SCALE = 1.0;


// ------------------------------------------------------------
// Three.js globals
// ------------------------------------------------------------

let scene;
let camera;
let renderer;
let controls;
let cubeGroup;

let cubeTemplate = null;
let latestTree = null;


// Use Z as the vertical axis, similar to your Meshcat / NumPy logic.
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);


// ------------------------------------------------------------
// Scene initialization
// ------------------------------------------------------------

export function initScene() {
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xf2f2f2);

    camera = new THREE.PerspectiveCamera(
        60,
        window.innerWidth / window.innerHeight,
        0.1,
        100
    );

    camera.up.set(0, 0, 1);
    camera.position.set(4, -6, 4);
    camera.lookAt(0, 0, 0);

    renderer = new THREE.WebGLRenderer({
        antialias: true,
    });

    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    document.body.appendChild(renderer.domElement);

    controls = new OrbitControls(camera, renderer.domElement);
    controls.target.set(0, 0, 0);
    controls.update();

    addLights();
    addHelpers();

    cubeGroup = new THREE.Group();
    cubeGroup.name = "cubeGroup";
    scene.add(cubeGroup);

    loadCubeModel();

    window.addEventListener("resize", onWindowResize);

    animate();
}


function addLights() {
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 1.2);
    directionalLight.position.set(4, -5, 8);
    scene.add(directionalLight);
}


function addHelpers() {
    const axes = new THREE.AxesHelper(2);
    scene.add(axes);

    /*
     * Three.js GridHelper normally lies in the XZ plane.
     * Because this project uses Z as the vertical axis, rotate the grid
     * into the XY plane.
     */
    const grid = new THREE.GridHelper(10, 10);
    grid.rotation.x = Math.PI / 2;
    scene.add(grid);
}


function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
}


function animate() {
    requestAnimationFrame(animate);

    controls.update();
    renderer.render(scene, camera);
}


// ------------------------------------------------------------
// GLB / GLTF loading
// ------------------------------------------------------------

function loadCubeModel() {
    const loader = new GLTFLoader();

    loader.load(
        CUBE_MODEL_URL,

        (gltf) => {
            cubeTemplate = gltf.scene;

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

        undefined,

        (error) => {
            console.error("Could not load cube model:", error);
        }
    );
}


// ------------------------------------------------------------
// Cube object creation
// ------------------------------------------------------------

function createCubeObject(node) {
    /*
     * This group represents one logical cube node.
     *
     * The GLB model is added as a visual child.
     * Other cube nodes can then be added as children of this group.
     */

    const cubeObject = new THREE.Group();

    cubeObject.name = `cube_${node.id.toString(16).toUpperCase()}`;
    cubeObject.userData.cubeId = node.id;
    cubeObject.userData.orientation = node.orientation;
    cubeObject.userData.port = node.port;

    if (cubeTemplate === null) {
        throw new Error("Cube model is not loaded yet.");
    }

    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);

    cubeObject.add(visualModel);

    return cubeObject;
}


// ------------------------------------------------------------
// Nested tree rendering
// ------------------------------------------------------------

export function redrawTree(rootNode) {
    latestTree = rootNode;

    if (cubeTemplate === null) {
        console.warn("Cube model not loaded yet. Tree will be drawn after loading.");
        return;
    }

    cubeGroup.clear();

    addCubeRecursive(rootNode, cubeGroup, true);
}


function addCubeRecursive(node, parentObject, isRoot) {
    const cubeObject = createCubeObject(node);

    const pose = isRoot
        ? localPoseForRoot(node)
        : localPoseForChild(node);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject); //this is where nesting and child parent relationship happens

    const children = node.children ?? [];

    for (const child of children) {
        addCubeRecursive(child, cubeObject, false);
    }
}