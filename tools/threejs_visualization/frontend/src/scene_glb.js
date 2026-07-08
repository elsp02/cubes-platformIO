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

const CUBE_MODEL_URL = "/assets/cube_model.glb";

// Change this only if your exported cube model is not 1 x 1 x 1 units.
const MODEL_SCALE = 25.0;


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

    //to match the render resolution with the device screen's physical pixel density
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); //maybe not needed

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
    const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
    topLight.position.set(4, -5, 8); //which is the best position for this light
    scene.add(topLight);
    topLight.castShadow = true;
}

// add Axes
function addHelpers() {
    const axes = new THREE.AxesHelper(2);
    scene.add(axes);

    const grid = new THREE.GridHelper(10, 10);
    grid.rotation.x = Math.PI / 2;
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
//animate function - render loop
function animate() {
    requestAnimationFrame(animate);

    controls.update();
    //scene rendering 
    renderer.render(scene, camera);
}

//------------------------------------------------------------
// Scene initialization - main function 
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
    cubeGroup = new THREE.Group();
    cubeGroup.name = "cubeGroup";
    scene.add(cubeGroup);

    loadCubeModel();

//Add a listener to the window, so we can resize the window and the camera
    window.addEventListener("resize", onWindowResize);

    animate();

}
//
function addGround() {
    const groundSize = 1000;

    const groundGeometry = new THREE.PlaneGeometry(
        groundSize,
        groundSize
    );

    const groundMaterial = new THREE.MeshStandardMaterial({
        color: 0xffffff,
        roughness: 0.8,
        metalness: 0.0,
    });

    const ground = new THREE.Mesh(groundGeometry, groundMaterial);

    ground.position.set(0, 0, -CUBE_SIZE / 2);

    ground.receiveShadow = true;

    scene.add(ground);
}


// ------------------------------------------------------------
// loads a template mesh for the cube
// ------------------------------------------------------------

function loadCubeModel() {
    const loader = new GLTFLoader();

    loader.load(
        CUBE_MODEL_URL,

        function (gltf)  {
            //sets glb file as cubeTemplate model
            cubeTemplate = gltf.scene;

            //receiving shadows is enabled
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

        function (error) {
            console.error("Could not load cube model:", error);
        }
    );
}


// ------------------------------------------------------------
// creates one cube instance
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

    //uses the template cube defined in loadCubeModel as the visual mode 
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