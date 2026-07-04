import * as THREE from "three";


export const CUBE_SIZE = 1.0;
export const GAP = 0.04;
export const PITCH = CUBE_SIZE + GAP;


// Parent port direction in the parent's local coordinate system.
export const PORT_DIRECTIONS = {
    0: new THREE.Vector3(1.0, 0.0, 0.0),    // parent +X port
    1: new THREE.Vector3(-1.0, 0.0, 0.0),   // parent -X port
    2: new THREE.Vector3(0.0, 1.0, 0.0),    // parent +Y port
    3: new THREE.Vector3(0.0, -1.0, 0.0),   // parent -Y port
    4: new THREE.Vector3(0.0, 0.0, 1.0),    // parent +Z port
};


function rotationX(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(1.0, 0.0, 0.0),
        angleRad
    );
}


function rotationY(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(0.0, 1.0, 0.0),
        angleRad
    );
}


function rotationZ(angleRad) {
    return new THREE.Quaternion().setFromAxisAngle(
        new THREE.Vector3(0.0, 0.0, 1.0),
        angleRad
    );
}


// Rotation that aligns the child cube's +Z side with the selected parent port.
const ATTACHMENT_ROTATIONS = {
    0: rotationY(Math.PI / 2.0),       // child +Z -> parent +X
    1: rotationY(-Math.PI / 2.0),      // child +Z -> parent -X
    2: rotationX(-Math.PI / 2.0),      // child +Z -> parent +Y
    3: rotationX(Math.PI / 2.0),       // child +Z -> parent -Y
    4: new THREE.Quaternion(),         // child +Z -> parent +Z
};


export function orientationToTwist(orientation) {
    const normalizedOrientation = orientation % 4;
    return rotationZ(normalizedOrientation * Math.PI / 2.0);
}


export function childQuaternionForPort(port, orientation) {
    const attachmentQuaternion = ATTACHMENT_ROTATIONS[port];

    if (!attachmentQuaternion) {
        throw new Error(`Unknown port: ${port}`);
    }

    const twistQuaternion = orientationToTwist(orientation);


    // in meshcat: child_rotation = attachment_rotation @ twist_rotation
    return attachmentQuaternion.clone().multiply(twistQuaternion);
}


export function rootQuaternionFromOrientation(orientation) {
    return orientationToTwist(orientation);
}


// Local pose of the root relative to cubeGroup / scene.
export function localPoseForRoot(rootNode) {
    return {
        position: new THREE.Vector3(0.0, 0.0, 0.0),
        quaternion: rootQuaternionFromOrientation(rootNode.orientation),
    };
}


// Local pose of a child relative to its direct parent.
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