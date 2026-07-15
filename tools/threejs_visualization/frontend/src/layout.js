// layout.js - pure geometry: where does each cube sit and how is it rotated?
//
// Position in the frontend:
//   ws_client.js receives the tree -> scene_glb.js walks it and asks
//   THIS FILE for the local pose (position + rotation) of every node.
//
// "Local" means relative to the direct parent cube. scene_glb.js nests
// the three.js objects the same way the tree is nested, so three.js
// multiplies the local poses up the chain into world positions on its
// own - no global math is needed here.
import * as THREE from "three";

//cube geometry
export const CUBE_SIZE = 1.0;
export const GAP = 0.04; //each side
export const PITCH = CUBE_SIZE + GAP; //dist from one cube center to next one


// maps every parent port index to direction in parent cubes local system - need to be changed
// (a child on port N sits PITCH away from its parent, in this direction)
export const PORT_DIRECTIONS = {
    0: new THREE.Vector3(1.0, 0.0, 0.0),    // parent +X port
    1: new THREE.Vector3(-1.0, 0.0, 0.0),   // parent -X port
    2: new THREE.Vector3(0.0, 1.0, 0.0),    // parent +Y port
    3: new THREE.Vector3(0.0, -1.0, 0.0),   // parent -Y port
    4: new THREE.Vector3(0.0, 0.0, 1.0),    // parent +Z port
};

// A cube's rotation is composed of TWO parts:
//   1. attachment rotation - fixed per port, turns the child so its
//      -Z face (the connector side) points at the parent port
//   2. twist rotation - the detected orientation value, an extra
//      0/90/180/270 degree turn around the child's own Z axis
//
// The three helpers below build quaternions (three.js' representation
// of a rotation) around one fixed axis each.

// rotation around X axis - used when the child hangs on a +/-Y port
function rotationX(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(1.0, 0.0, 0.0),
        angleRad
    );
}

// rotation around Y axis - used when the child hangs on a +/-X port
function rotationY(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(0.0, 1.0, 0.0),
        angleRad
    );
}

// rotation around Z axis - used for the detected orientation value (twist)
function rotationZ(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(0.0, 0.0, 1.0),
        angleRad
    );
}


// Rotation that aligns the child cube's -Z side with the selected parent port.
const ATTACHMENT_ROTATIONS = {
    0: rotationY(Math.PI / 2.0),       // child -Z -> parent +X port
    1: rotationY(-Math.PI / 2.0),      // child -Z -> parent -X port
    2: rotationX(-Math.PI / 2.0),      // child -Z -> parent +Y port
    3: rotationX(Math.PI / 2.0),       // child -Z -> parent -Y port
    4: new THREE.Quaternion(),         // child -Z -> parent +Z port (identity: already aligned)
}; //example: if child is connected to port 0 -> rotate +90 around Y axis

// converts detected orientation value into rotation matrix
// values: 0=0°, 1=90°, 2=180°, 3=270° around Z axis
export function orientationToTwist(orientation) {
    // % 4 is a safety guard: the firmware only sends 0-3, but if a
    // corrupt value ever slipped through, it would otherwise become a
    // silent >360° rotation instead of an obviously wrong pose
    const normalizedOrientation = orientation % 4;
    return rotationZ(normalizedOrientation * Math.PI / 2.0);
}

//calculates complete rotation of child cube: attachment rotation combined with twist rotation
export function childQuaternionForPort(port, orientation) {
    const attachmentQuaternion = ATTACHMENT_ROTATIONS[port];

    if (!attachmentQuaternion) {
        throw new Error(`Unknown port: ${port}`);
    }

    const twistQuaternion = orientationToTwist(orientation);

    // combine the two rotations; ORDER MATTERS with quaternions:
    // attachment * twist = "first twist around own Z, then attach to
    // the port" (same order as the meshcat version:
    // child_rotation = attachment_rotation @ twist_rotation).
    // .clone() because multiply() modifies the left operand in place
    // and ATTACHMENT_ROTATIONS must stay untouched for the next cube.
    return attachmentQuaternion.clone().multiply(twistQuaternion);
}


// the root has no parent port, only its own twist
export function rootQuaternionFromOrientation(orientation) {
    return orientationToTwist(orientation);
}


//----------------- actual pose calculation functions -----------------
// called in scene_glb.js (addCubeRecursive)

// Calculate local pose of the root relative to scene - no parent port, -Z always facing down to -Z axis.
export function localPoseForRoot(rootNode) {
    return {
        position: new THREE.Vector3(0.0, 0.0, 0.0),
        quaternion: rootQuaternionFromOrientation(rootNode.orientation),
    };
}


// Calculate local pose of a child relative to its direct parent:
// position = port direction scaled to PITCH, rotation = attachment + twist.
export function localPoseForChild(childNode) {
    if (childNode.port === null || childNode.port === undefined) {
        throw new Error(`Child cube ${childNode.id} has no port value.`);
    }

    const portDirection = PORT_DIRECTIONS[childNode.port];

    if (!portDirection) {
        throw new Error(`Unknown port ${childNode.port} on cube ${childNode.id}.`);
    }

    // .clone() so the shared PORT_DIRECTIONS vector is not modified
    const localPosition = portDirection.clone().multiplyScalar(PITCH);

    const localQuaternion = childQuaternionForPort(
        childNode.port,
        childNode.orientation
    );

    return {
        position: localPosition,
        quaternion: localQuaternion,
    };
}
