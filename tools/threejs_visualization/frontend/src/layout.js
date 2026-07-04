import * as THREE from "three";

//cube geometry
export const CUBE_SIZE = 1.0;
export const GAP = 0.04; //each side
export const PITCH = CUBE_SIZE + GAP; //dist from one cube center to next one


// maps every parent port index to direction in parent cubes local system - need to be changed
export const PORT_DIRECTIONS = {
    0: new THREE.Vector3(1.0, 0.0, 0.0),    // parent +X port
    1: new THREE.Vector3(-1.0, 0.0, 0.0),   // parent -X port
    2: new THREE.Vector3(0.0, 1.0, 0.0),    // parent +Y port
    3: new THREE.Vector3(0.0, -1.0, 0.0),   // parent -Y port
    4: new THREE.Vector3(0.0, 0.0, 1.0),    // parent +Z port
};

// rotation matrix around X axis - for -Z Face of child cube points to parents +/-Y port
function rotationX(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(1.0, 0.0, 0.0),
        angleRad
    );
}

// rotation matrix around Y axis - for -Z Face of child cube points to parents +/-X port
function rotationY(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(0.0, 1.0, 0.0),
        angleRad
    );
}

// rotation matrix around Z axis - for cubes detected orientation value
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
    4: new THREE.Quaternion(),         // child -Z -> parent +Z port
}; //example: if child is connected to port 0 -> rotate +90 around Y axis

// converts detected orientation value into rotation matrix
// values: 0=0°, 1=90°, 2=180°, 3=270° around Z axis
export function orientationToTwist(orientation) {
    const normalizedOrientation = orientation % 4; // ensure orientation is in range [0, 3] - do i need this?
    return rotationZ(normalizedOrientation * Math.PI / 2.0);
}

//calculates complete rotation of child cube including fac attachement rotation and twist rotation 
export function childQuaternionForPort(port, orientation) {
    const attachmentQuaternion = ATTACHMENT_ROTATIONS[port];

    if (!attachmentQuaternion) {
        throw new Error(`Unknown port: ${port}`);
    }

    const twistQuaternion = orientationToTwist(orientation);

    //combine two rotations to get final rotation of child 
    // in meshcat: child_rotation = attachment_rotation @ twist_rotation
    return attachmentQuaternion.clone().multiply(twistQuaternion);
}


export function rootQuaternionFromOrientation(orientation) {
    return orientationToTwist(orientation);
}


//----------------- actual pose calculation functions -----------------
// called in scene.js

// Calculate local pose of the root relative to scene - no parent port, -Z always facing down to -Z axis.
export function localPoseForRoot(rootNode) {
    return {
        position: new THREE.Vector3(0.0, 0.0, 0.0),
        quaternion: rootQuaternionFromOrientation(rootNode.orientation),
    };
}


// Calculate local pose of a child relative to its direct parent.
export function localPoseForChild(childNode) {
    if (childNode.port === null || childNode.port === undefined) {
        throw new Error(`Child cube ${childNode.id} has no port value.`);
    }

    const portDirection = PORT_DIRECTIONS[childNode.port];

    if (!portDirection) {
        throw new Error(`Unknown port ${childNode.port} on cube ${childNode.id}.`);
    }

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