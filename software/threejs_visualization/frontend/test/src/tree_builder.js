// tree_builder.js - shared core for turning a target tree definition
// into a three.js object: load the cube model once, build a nested
// THREE.Group from a tree definition, and fit a camera to it.
//
// Used by BOTH tree_thumbnail.js (one-shot thumbnails for
// the cards) and tree_preview.js (the live, orbit-able view) - same
// code builds the tree in both places, so a card's preview and the
// live scene it opens are guaranteed to match.
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

import {
    localPoseForRoot,
    localPoseForChild,
} from "../../src/layout.js";

// page-relative: the html lives in /test/, the model in /test/assets/
const CUBE_MODEL_URL = "./assets/cube_model_z.glb";
const MODEL_SCALE = 25.0;

// Z axis as the vertical axis
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);

//--------------------------------------------------------
// Cube Model Loading
let cubeTemplate = null;

export function loadCubeTemplate() {
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

// optional per-node build-status tint, mirrors scene_glb.js's live status
// colors so a mock "in progress" tree looks consistent with the real app.
// Nodes without a `status` field (plain target-tree JSON) render untinted.
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
function applyStatusAppearance(visualModel, status) {
    const appearance = STATUS_APPEARANCE[status];

    if (!appearance) {
        return; // no/unknown status: leave the model in its original look
    }

    visualModel.traverse((object) => {
        if (!object.isMesh) {
            return;
        }

        const materials = Array.isArray(object.material)
            ? object.material
            : [object.material];

        const tinted = materials.map((material) => {
            const clone = material.clone();

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

//represents one cube
function createCubeObject(node) {
    const cubeObject = new THREE.Group();

    if (cubeTemplate === null) {
        throw new Error("cube model is not loaded yet");
    }

    const visualModel = cubeTemplate.clone(true);
    visualModel.scale.setScalar(MODEL_SCALE);

    if (node.status) {
        applyStatusAppearance(visualModel, node.status);
    }

    cubeObject.add(visualModel);

    return cubeObject;
}

//--------------------------------------------------------------
//building functions
function addCubeRecursive(node, parentObject, isRoot) {
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
export function buildTreeGroup(rootNode) {
    const treeGroup = new THREE.Group();
    treeGroup.name = "targetTreeGroup";

    addCubeRecursive(rootNode, treeGroup, true);

    return treeGroup;
}

//camera position is computed from the content it's photographing (adapts to amount of cubes and size of construction)
export function fitCameraToBox(camera, box) {
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
