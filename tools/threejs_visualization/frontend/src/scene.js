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

    window.addEventListener("resize", onWindowResize);

    animate();
}


// ------------------------------------------------------------
// Lights and helpers
// ------------------------------------------------------------

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


// ------------------------------------------------------------
// Window resize handling
// ------------------------------------------------------------

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
}


// ------------------------------------------------------------
// Render loop
// ------------------------------------------------------------

function animate() {
    requestAnimationFrame(animate);

    controls.update();
    renderer.render(scene, camera);
}


// ------------------------------------------------------------
// Cube object creation
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

export function redrawTree(rootNode) {
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

    parentObject.add(cubeObject); // Parent-child nesting happens here.

    const children = node.children ?? [];

    for (const child of children) {
        addCubeRecursive(child, cubeObject, false);
    }
}