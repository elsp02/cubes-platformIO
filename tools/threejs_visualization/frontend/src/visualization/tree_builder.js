// tree_builder.js - shared core for turning a tree definition into a
// three.js object: load the cube model once, build a nested THREE.Group
// from a tree, and fit a camera to it.
//
// Used by tree_thumbnail.js (one-shot thumbnails for the cards),
// tree_preview.js (the live, orbit-able view) AND scene_glb.js (the
// live build scene on bauen.html) - the same code builds the tree
// everywhere, so all views are guaranteed to match.
//
// Views that need extra per-cube styling (e.g. the status tinting on
// bauen.html) pass a `decorate(cubeObject, view)` callback to
// buildTreeGroup(); plain views just call buildTreeGroup(tree).
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

import {
    localPoseForRoot,
    localPoseForChild,
} from "../layout.js";

// absolute URL: works from every html page under the vite root
const CUBE_MODEL_URL = "/assets/cube_model_z_v2.glb";
const MODEL_SCALE = 25.0;

// Z axis as the vertical axis
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);

//--------------------------------------------------------
// Cube Model Loading
//
// Loading the GLB file is asynchronous (it is an HTTP request), so the
// template is null until the load finishes. Every drawn cube is a CLONE
// of this template. The promise is cached: no matter how many modules
// call loadCubeTemplate(), the file is fetched exactly once per page.
let cubeTemplate = null;
let templatePromise = null;

export function loadCubeTemplate() {
    if (templatePromise !== null) {
        return templatePromise;
    }

    templatePromise = new Promise((resolve, reject) => {
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

    return templatePromise;
}

export function isCubeTemplateLoaded() {
    return cubeTemplate !== null;
}

//--------------------------------------------------------
// node normalization
/*
 * Normalizes one node so the builder works with every tree format:
 *   target tree JSON: cube_type, orientation, port, children
 *   evaluated tree (server): node_id, status, error_mask, expected_*
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
        cubeType: node.cube_type ?? node.expected_type ?? 0,
        orientation: node.orientation ?? node.expected_orientation ?? 0,
        port: node.port,
        children: node.children ?? [],
    };
}

//represents one cube
function createCubeObject(view) {
    const cubeObject = new THREE.Group();

    if (cubeTemplate === null) {
        throw new Error("cube model is not loaded yet");
    }

    // clone(true) = deep clone including all child meshes
    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);
    cubeObject.add(visualModel);

    return cubeObject;
}

//--------------------------------------------------------------
//building functions
//
// walks the tree depth-first and mirrors it as nested three.js groups:
// each cube object is added as a CHILD of its parent's object, so the
// local poses from layout.js are automatically stacked up the chain
function addCubeRecursive(node, parentObject, isRoot, decorate) {
    const view = nodeView(node);

    // blocked slots (and everything below them) are not buildable yet
    // -> hidden (target trees have no status, so nothing is skipped there)
    if (view.status === "blocked") {
        return;
    }

    const cubeObject = createCubeObject(view);

    if (decorate) {
        decorate(cubeObject, view);
    }

    const pose = isRoot
        ? localPoseForRoot(view)
        : localPoseForChild(view);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject);

    for (const child of view.children) {
        addCubeRecursive(child, cubeObject, false, decorate);
    }
}

//recursive main function; decorate is optional per-cube styling
export function buildTreeGroup(rootNode, decorate = null) {
    const treeGroup = new THREE.Group();
    treeGroup.name = "targetTreeGroup";

    addCubeRecursive(rootNode, treeGroup, true, decorate);

    return treeGroup;
}

//camera position is computed from the content it's photographing (adapts to amount of cubes and size of construction)
export function fitCameraToBox(camera, box) {
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = THREE.MathUtils.degToRad(camera.fov);
    let dist = (maxDim / 2) / Math.tan(fov / 2);
    dist *= 2; // distance from the construction

    const dir = new THREE.Vector3(0.3, -1, 0.2).normalize(); //front shot
    camera.position.copy(center).addScaledVector(dir, dist);

    camera.near = dist / 100;
    camera.far = dist * 100;
    camera.lookAt(center);
    camera.updateProjectionMatrix();
}
