// renders all target trees and snapshots it for card visualization

import * as THREE from "three";
import {GLTFLoader} from "three/addons/loaders/GLTFLoader.js";

//for Position Determination
import {
    localPoseForRoot,
    localPoseForChild,
} from "../../src/layout.js";

import { TARGET_TREES } from "../target_trees/index.js";

//Cube Configurations
const CUBE_MODEL_URL = "./assets/cube_model_z.glb";
const MODEL_SCALE = 25.0;

//Resolution/ratio for the thumbnail snapshot to match the 3:4 ratio of the cards
const THUMBNAIL_WIDTH = 600;
const THUMBNAIL_HEIGHT = 800;

//Z axis as the vertical axis
THREE.Object3D.DEFAULT_UP.set(0,0,1);

//--------------------------------------------------------

// Cube Model Loading
let cubeTemplate = null;

function loadCubeTemplate() {
    //was ist new Promise
    return new Promise((resolve, reject) => {
        const loader = new GLTFLoader();

        loader.load(
            CUBE_MODEL_URL,

            (gltf) => {
                cubeTemplate = gltf.scene;

                // enable shadows on every mesh inside the model
                cubeTemplate.traverse((object) => {
                    if (object.isMesh) {
                        object.castShadow = true;
                        object.receiveShadow = true;
                    }
                });

                resolve();
            },

            undefined, // progress callback, not needed

            (error) => reject(error)
        );
    });
}

//represents one cube
function createCubeObject(view){
    const cubeObject = new THREE.Group();

    if (cubeTemplate === null) {
        throw new Error("cube model is not loaded yet");
    }

    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);
    cubeObject.add(visualModel);

    return cubeObject;


}

//--------------------------------------------------------------
//building functions
function addCubeRecursive(node, parentObject, isRoot){
    const cubeObject = createCubeObject(node);

    const pose = isRoot
        ? localPoseForRoot(node)
        : localPoseForChild(node);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject);

    for (const child of node.children ?? []) {
        addCubeRecursive(child, cubeObject, false);
    }
}

//recursive main function
export function buildTreeGroup(rootNode){
    const treeGroup = new THREE.Group();
    treeGroup.name = "targetTreeGroup";

    addCubeRecursive(rootNode, treeGroup, true);

    return treeGroup;
}

//--------------------------------------------------------
// Thumbnail rendering

//camera position is computed from the content it`s photographing (adapts to amount of cubes and size of construction)
function fitCameraToBox(camera, box) {
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = THREE.MathUtils.degToRad(camera.fov);
    let dist = (maxDim / 2) / Math.tan(fov / 2);
    dist *= 2.5; // distance from the construction

    const dir = new THREE.Vector3(0.3, -1, 0.2).normalize(); //front shot
    camera.position.copy(center).addScaledVector(dir, dist);

    camera.near = dist / 100;
    camera.far = dist * 100;
    camera.lookAt(center);
    camera.updateProjectionMatrix();
}
//builds small scene around construction
function renderTreeToImage(treeDefinition){
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT, false);
    renderer.setPixelRatio(1); // fixed output resolution, DPR-independent
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    
    //initialize scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x757575);

    // same light setup as scene_test.js, so the preview matches the look
    scene.add(new THREE.AmbientLight(0xffffff, 0.7));
    
    const topLight = new THREE.DirectionalLight(0xffffff, 1.2);
    topLight.position.set(4, -5, 8);
    topLight.castShadow = true;
    scene.add(topLight);
    
    //add Tree construction 
    const treeGroup = buildTreeGroup(treeDefinition);
    scene.add(treeGroup);
    
    // ground directly under the lowest cube, receives the shadows
    const box = new THREE.Box3().setFromObject(treeGroup);
    const ground = new THREE.Mesh(
        new THREE.PlaneGeometry(1000, 1000),
        new THREE.MeshStandardMaterial({
            color: 0x757575,
            roughness: 0.0,
            metalness: 0.0,
        })
    );
    ground.receiveShadow = true;
    ground.position.z = box.min.z - 0.001;
    scene.add(ground);
    
    // add camera - fit camera to box calculates the best position
    const camera = new THREE.PerspectiveCamera(
        60,
        THUMBNAIL_WIDTH / THUMBNAIL_HEIGHT,
        0.1,
        1000
    );
    camera.up.set(0, 0, 1);
    fitCameraToBox(camera, box);
    
    renderer.render(scene, camera);
    
    // must happen in the SAME tick as render(): the browser may clear
    // the WebGL drawing buffer afterwards (no preserveDrawingBuffer)
    const dataUrl = renderer.domElement.toDataURL("image/png");
    
    renderer.dispose(); // free the WebGL context right away
    
    return dataUrl;
}

//---------------------------------------------------

//MAIN MAIN Function
// calls all functions and creates an image for the cards. one card per entry in TARGET_TREES (created in target_trees/index.js)
async function showTargetTreeThumbnails() {
    try {
        await loadCubeTemplate();

        const scrollContainer = document.querySelector(".scroll-container");

        for (const { id, name, tree } of TARGET_TREES) {
            const dataUrl = renderTreeToImage(tree);

            const card = document.createElement("div");
            card.className = "card aspect-ratio-3-4";
            card.id = `card-${id}`;

            const img = document.createElement("img");
            img.src = dataUrl;
            img.alt = `Zielbaum: ${name}`;

            const label = document.createElement("p");
            label.className = "typo-handwriting";
            label.textContent = name;

            card.append(img, label);
            scrollContainer.append(card);
        }

        console.log(`Created ${TARGET_TREES.length} target tree cards.`);
    } catch (error) {
        console.error("Could not create target tree thumbnails:", error);
    }
}

showTargetTreeThumbnails();