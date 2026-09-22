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
    nodeTypeFromId,
    CUBE_SIZE,
    TYPE_CUBE,
    TYPE_SMASHED,
    //TYPE_WEDGE,
} from "../layout.js";

// one GLB model per cube type; absolute URLs work from every html page
// under the vite root. All models share the same conventions: 0.04
// units edge length (MODEL_SCALE brings that to 1.0), origin 0.5 above
// the -Z attachment face (see the origin convention note in layout.js).
const CUBE_MODEL_URLS = {
    [TYPE_CUBE]:    "/assets/cube_model_z_v3.glb",
    [TYPE_SMASHED]: "/assets/cube_model_z_v3_smashed.glb",
    //[TYPE_WEDGE]:   "/assets/cube_model_z_pyramide.glb",
};
const MODEL_SCALE = 25.0;

// Z axis as the vertical axis
THREE.Object3D.DEFAULT_UP.set(0, 0, 1);

//--------------------------------------------------------
//--------------------------------------------------------
// Cube Model Loading
//
// Loading the GLB files is asynchronous (they are HTTP requests), so
// the templates are missing until the load finishes. Every drawn cube
// is a CLONE of its type's template. The promise is cached: no matter
// how many modules call loadCubeTemplate(), each file is fetched
// exactly once per page.
const cubeTemplates = {};   // cube type -> loaded GLB scene
let templatePromise = null;

function loadOneTemplate(loader, cubeType, url) {
    return new Promise((resolve, reject) => {
        loader.load(
            url,

            (gltf) => {
                // enable shadows on every mesh inside the model
                gltf.scene.traverse((object) => {
                    if (object.isMesh) {
                        object.castShadow = true;
                        object.receiveShadow = true;
                    }
                });

                cubeTemplates[cubeType] = gltf.scene;
                resolve();
            },

            undefined, // progress callback, not needed

            (error) => reject(error)
        );
    });
}

export function loadCubeTemplate() {
    if (templatePromise !== null) {
        return templatePromise;
    }

    const loader = new GLTFLoader();

    // load all type models in parallel; ready when every one arrived
    templatePromise = Promise.all(
        Object.entries(CUBE_MODEL_URLS).map(
            ([cubeType, url]) => loadOneTemplate(loader, Number(cubeType), url)
        )
    );

    return templatePromise;
}

export function isCubeTemplateLoaded() {
    return Object.keys(CUBE_MODEL_URLS).every(
        (cubeType) => cubeTemplates[cubeType] !== undefined
    );
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
        // physically present cubes carry their type in the upper 3 bits
        // of the NODE_ID; target/ghost nodes state it explicitly
        cubeType: id !== null
            ? nodeTypeFromId(id)
            : (node.cube_type ?? node.expected_type ?? TYPE_CUBE),
        orientation: node.orientation ?? node.expected_orientation ?? 0,
        port: node.port,
        children: node.children ?? [],
    };
}

//--------------------------------------------------------------
// Root marker
//
// A flat frame lying on the ground under the root cube, so it's
// visually clear which cube is the starting point of the construction.
// Built from 4 separate edge segments (not one shape-with-hole mesh) so
// the front edge (-Y side) can carry its own accent color - the same
// one the front arrow below uses - while the other 3 edges stay the
// regular marker color.
const ROOT_MARKER_SIZE = 1.5 * CUBE_SIZE;      // outer edge length
const ROOT_MARKER_THICKNESS = 0.1 * CUBE_SIZE; // frame width
const ROOT_MARKER_COLOR = 0x000000;
const ROOT_FRONT_ACCENT_COLOR = 0x117e2f; // shared by the front edge and the front arrow

// one flat rectangular segment of the frame, spanning [minX,maxX] x [minY,maxY]
function createEdgeSegment(minX, maxX, minY, maxY, color) {
    const geometry = new THREE.PlaneGeometry(maxX - minX, maxY - minY);
    const material = new THREE.MeshBasicMaterial({ color, side: THREE.DoubleSide });

    const segment = new THREE.Mesh(geometry, material);
    segment.position.set((minX + maxX) / 2, (minY + maxY) / 2, 0);

    return segment;
}

function createRootMarker() {
    const outerHalf = ROOT_MARKER_SIZE / 2;
    const innerHalf = outerHalf - ROOT_MARKER_THICKNESS;

    const marker = new THREE.Group();
    marker.name = "rootMarker";

    // front/back segments span the full width; left/right fill only the
    // remaining inner gap so the corners aren't drawn twice
    marker.add(createEdgeSegment(-outerHalf, outerHalf, -outerHalf, -innerHalf, ROOT_FRONT_ACCENT_COLOR)); // front (-Y)
    marker.add(createEdgeSegment(-outerHalf, outerHalf, innerHalf, outerHalf, ROOT_MARKER_COLOR));         // back (+Y)
    marker.add(createEdgeSegment(-outerHalf, -innerHalf, -innerHalf, innerHalf, ROOT_MARKER_COLOR));       // left (-X)
    marker.add(createEdgeSegment(innerHalf, outerHalf, -innerHalf, innerHalf, ROOT_MARKER_COLOR));         // right (+X)

    // sits flat on the XY plane, just below the root cube's bottom
    // face (independent of the root's own twist rotation)
    marker.position.z = -CUBE_SIZE / 2 - 0.002;

    return marker;
}

//--------------------------------------------------------------
// Front arrow
//
// A flat arrow lying in front of the root marker, on the -Y side,
// pointing back along +Y towards the brick. -Y is "front" purely by
// scene convention (no real-world compass tie, no camera tilt/X
// offset) - it's the fixed reference for how to line up the baseplate.
const FRONT_ARROW_LENGTH = 0.6 * CUBE_SIZE;
const FRONT_ARROW_WIDTH = 0.3 * CUBE_SIZE;
const FRONT_ARROW_GAP = 0.15 * CUBE_SIZE; // empty space between marker edge and arrow tip

function createFrontArrow() {
    const tipY = -ROOT_MARKER_SIZE / 2 - FRONT_ARROW_GAP; // a bit off the marker's front edge
    const tailY = tipY - FRONT_ARROW_LENGTH;       // further out in front
    const headLength = FRONT_ARROW_LENGTH * 0.45;
    const headStartY = tipY - headLength;
    const halfWidth = FRONT_ARROW_WIDTH / 2;
    const shaftHalfWidth = halfWidth * 0.4;

    // points toward +Y (the brick), tail sits out front in -Y
    const shape = new THREE.Shape();
    shape.moveTo(-shaftHalfWidth, tailY);
    shape.lineTo(-shaftHalfWidth, headStartY);
    shape.lineTo(-halfWidth, headStartY);
    shape.lineTo(0, tipY);
    shape.lineTo(halfWidth, headStartY);
    shape.lineTo(shaftHalfWidth, headStartY);
    shape.lineTo(shaftHalfWidth, tailY);
    shape.closePath();

    const geometry = new THREE.ShapeGeometry(shape);
    const material = new THREE.MeshBasicMaterial({
        color: ROOT_FRONT_ACCENT_COLOR,
        side: THREE.DoubleSide,
    });

    const arrow = new THREE.Mesh(geometry, material);
    arrow.name = "frontArrow";
    arrow.position.z = -CUBE_SIZE / 2 - 0.002;

    return arrow;
}

//represents one cube; the model is picked by the node's cube type
function createCubeObject(view) {
    const cubeObject = new THREE.Group();

    let template = cubeTemplates[view.cubeType];

    if (template === undefined) {
        // unknown type (e.g. corrupt node id): draw SOMETHING instead
        // of crashing the whole redraw, but make it visible in the console
        console.warn(`No model for cube type ${view.cubeType}, falling back to the normal cube.`);
        template = cubeTemplates[TYPE_CUBE];
    }

    if (template === undefined) {
        throw new Error("cube models are not loaded yet");
    }

    // clone(true) = deep clone including all child meshes
    const visualModel = template.clone(true);
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
// parentType = cube type of the direct parent; it decides which port
// geometry table in layout.js applies to this child (port numbers are
// type-relative). The root has no parent, so parentType is null there.
function addCubeRecursive(node, parentObject, isRoot, decorate, parentType) {
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
        : localPoseForChild(view, parentType);

    cubeObject.position.copy(pose.position);
    cubeObject.quaternion.copy(pose.quaternion);

    parentObject.add(cubeObject);

    for (const child of view.children) {
        addCubeRecursive(child, cubeObject, false, decorate, view.cubeType);
    }
}

//recursive main function; decorate is optional per-cube styling
export function buildTreeGroup(rootNode, decorate = null) {
    const treeGroup = new THREE.Group();
    treeGroup.name = "targetTreeGroup";

    addCubeRecursive(rootNode, treeGroup, true, decorate, null);
    treeGroup.add(createRootMarker());
    treeGroup.add(createFrontArrow());

    return treeGroup;
}

//camera position is computed from the content it's photographing (adapts to amount of cubes and size of construction)
export function fitCameraToBox(camera, box) {
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = THREE.MathUtils.degToRad(camera.fov);
    let dist = (maxDim / 2) / Math.tan(fov / 2);
    dist *= 3; // distance from the construction

    const dir = new THREE.Vector3(0.3, -1, 0.2).normalize(); //front shot
    camera.position.copy(center).addScaledVector(dir, dist);

    camera.near = dist / 100;
    camera.far = dist * 100;
    camera.lookAt(center);
    camera.updateProjectionMatrix();
}
