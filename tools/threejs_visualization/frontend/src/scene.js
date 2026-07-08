//main ruft zuerst initScene auf, dann redraw_tree
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

import {
    CUBE_SIZE,
    localPoseForRoot,
    localPoseForChild,
} from "./layout.js";

// ------------------------------------------------------------
// Three.js globals
// ------------------------------------------------------------

let scene;
let camera;
let renderer;
let controls;
let cubeGroup;


// Use Z as the vertical axis, similar to your Meshcat / NumPy logic.
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);

//-----------------------------------------------------------
// function definitions 
//-----------------------------------------------------------
// add camera - 
function addCamera(){
    //create a new camera with positions and angles - fov, aspect, closest visible distance from camera, farest ...
    const camera = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 1, 100 );
    
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
    const renderer = new THREE.WebGLRender({alpha: true, antialias:true});
    renderer.setSize(window.innerWidth, window.innerHeight);

    //to match the render resolution with the device screen's physical pixel density
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); //maybe not needed

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
    controls.update;

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

// cubeGroup = contains the complete cube construction
    cubeGroup = new THREE.Group();
    cubeGroup.name = "cubeGroup";
    scene.add(cubeGroup);

//Add a listener to the window, so we can resize the window and the camera
    window.addEventListener("resize", onWindowResize);

    animate();

}
// ------------------------------------------------------------
// Cube object creation - should be replaced by glb file code
// ------------------------------------------------------------

function createCubeObject(node) {
    /*
     * This group represents one logical cube node.
     *
     * The generated cube mesh is added as a visual child.
     * Other cube nodes can then be added as children of this group.
     */

    const cubeObject = new THREE.Group();

    cubeObject.name = `cube_${node.id.toString(16).toUpperCase()}`;
    cubeObject.userData.cubeId = node.id;
    cubeObject.userData.orientation = node.orientation;
    cubeObject.userData.port = node.port;

    const geometry = new THREE.BoxGeometry(
        CUBE_SIZE,
        CUBE_SIZE,
        CUBE_SIZE
    );

    const material = new THREE.MeshStandardMaterial({
        color: 0x808080,
        roughness: 0.6,
        metalness: 0.0,
    });

    const cubeMesh = new THREE.Mesh(geometry, material);
    cubeObject.add(cubeMesh);

    /*
     * Optional black outline.
     * This makes the cube borders easier to see.
     */
    const edges = new THREE.EdgesGeometry(geometry);
    const edgeMaterial = new THREE.LineBasicMaterial({
        color: 0x000000,
    });

    const edgeLines = new THREE.LineSegments(edges, edgeMaterial);
    cubeObject.add(edgeLines);

    return cubeObject;
}


// ------------------------------------------------------------
// Nested tree rendering
// ------------------------------------------------------------
// called from main.js and redraws tree
export function redrawTree(rootNode) {
    cubeGroup.clear();

    addCubeRecursive(rootNode, cubeGroup, true);
}


function addCubeRecursive(node, parentObject, isRoot) {
    const cubeObject = createCubeObject(node);

    const pose = isRoot
        ? localPoseForRoot(node) // in layout.js
        : localPoseForChild(node); // in layout.js

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject); // adds cubeObject to scene (places it in the scene graph)

    const children = node.children ?? [];

    //recursive child drawing
    for (const child of children) {
        addCubeRecursive(child, cubeObject, false);
    }
}
