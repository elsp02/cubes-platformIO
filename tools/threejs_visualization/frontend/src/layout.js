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
export const GAP = 0.01; //each side
export const PITCH = CUBE_SIZE + GAP; //dist from one cube center to next one

// ------------------------------------------------------------
// Cube types
// ------------------------------------------------------------
// NODE_ID layout is TTTIIIII (3 bits type, 5 bits instance) - the same
// split as node_type() in backend/target_tree.py; keep the two in sync.
export const TYPE_SHIFT = 5;

export const TYPE_CUBE    = 0;  // normal cube: children on all 5 free faces
export const TYPE_SMASHED = 1;  // side faces smashed: children only on +Z
//export const TYPE_WEDGE   = 2;  // "pyramid": square -Z/+X faces, 45 degree slope

// extracts the 3-bit cube type from a full NODE_ID
export function nodeTypeFromId(nodeId) {
    return nodeId >> TYPE_SHIFT;
}

/*
// maps every parent port index to direction in parent cubes local system - need to be changed
// (a child on port N sits PITCH away from its parent, in this direction)
export const PORT_DIRECTIONS = {
    0: new THREE.Vector3(-1.0, 0.0, 0.0),    //  parent -x port
    1: new THREE.Vector3(0.0,-1.0, 0.0),   //  parent -y port
    2: new THREE.Vector3(0.0, 0.0, 1.0),    //  parent +z port
    3: new THREE.Vector3(1.0, 0.0, 0.0),   //  parent x port 
    4: new THREE.Vector3(0.0, 1.0, 0.0),    //  parent y port 
};


// Rotation that aligns the child cube's -Z side with the selected parent port.
const ATTACHMENT_ROTATIONS = {
    0: rotationY(-Math.PI / 2.0),       // child -Z -> parent -X port
    1: rotationX(-Math.PI / 2.0),      // child -Z -> parent -Y port
    2: new THREE.Quaternion(),         // child -Z -> parent +Z port (identity: already aligned)
    3: rotationY(Math.PI / 2.0),       // child -Z -> parent -X port
    4: rotationX(Math.PI/2.0)         // child -Z -> parent +Y port
}; //example: if child is connected to port 0 -> rotate -90 around Y axis
*/

// A cube's rotation is composed of TWO parts:
//   1. attachment rotation - fixed per port, turns the child so its
//      -Z face (the connector side) points at the parent port
//   2. twist rotation - the detected orientation value, an extra
//      0/90/180/270 degree turn around the child's own Z axis
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

// ------------------------------------------------------------
// Per-type port geometry
// ------------------------------------------------------------
// Port numbers are TYPE-RELATIVE: bit N of the firmware child_mask is
// simply the Nth entry of that cube type's children[] wiring array
// (0-based), so the same port number can mean a different face on a
// different cube type. This table is the single place that gives each
// (type, port) pair its geometry:
//
//   direction  - unit vector from the parent's center towards the child
//   distance   - parent center -> child center along that direction
//   attachment - rotation that points the child's -Z (connector) face
//                at the parent port
//
// Target trees in the backend use the same type-relative port numbers.
//
// ORIGIN CONVENTION (all GLB models): the origin sits 0.5 above the
// center of the -Z attachment face - for cube and wedge that is simply
// the bounding-box center, for the half-height smashed cube the origin
// lies at its TOP face. This keeps every cube-as-child calculation
// identical across types; only the parent-side face offsets differ.
//
// WEDGE geometry (matches cube_model_z_pyramide.glb): the square
// vertical face is on +Y, the 45 degree slope falls towards -Y, so the
// slope's outward normal is (0, -1, 1)/sqrt(2); the triangle faces are
// +/-X. The slope face of a right isosceles triangle inscribed in the
// unit square passes through the bounding-box center, so a child on
// the slope sits only CUBE_SIZE/2 + GAP away from the wedge center -
// closer than PITCH.
const SLOPE_DISTANCE = CUBE_SIZE / 2.0 + GAP;
// SMASHED geometry (matches cube_model_z_smashed.glb): half height,
// body from -0.5 to 0 in Z, so its top face lies AT origin height and
// a child on top sits only CUBE_SIZE/2 + GAP above the origin.
const SMASHED_TOP_DISTANCE = CUBE_SIZE / 2.0 + GAP;

const PORT_GEOMETRY = {
    [TYPE_CUBE]: {
        0: { direction: new THREE.Vector3(-1.0, 0.0, 0.0),  distance: PITCH, attachment: rotationY(-Math.PI / 2.0) },   //  parent -x port
        1: { direction: new THREE.Vector3(0.0, -1.0, 0.0), distance: PITCH, attachment: rotationX(-Math.PI / 2.0) },  //  parent -y port
        2: { direction: new THREE.Vector3(0.0, 0.0, 1.0),  distance: PITCH, attachment: new THREE.Quaternion() },  //  parent +z port -> identity: already aligned
        3: { direction: new THREE.Vector3(1.0, 0.0, 0.0), distance: PITCH, attachment: rotationY(Math.PI / 2.0) },   //  parent x port
        4: { direction: new THREE.Vector3(0.0, 1.0, 0.0),  distance: PITCH, attachment: rotationX(Math.PI/2.0) },     //  parent y port
    },

    [TYPE_SMASHED]: {
        0: { direction: new THREE.Vector3(0.0, 0.0, 1.0),  distance: SMASHED_TOP_DISTANCE, attachment: new THREE.Quaternion() },     // +Z, the only usable face
    },
/*
    [TYPE_WEDGE]: {
        0: { direction: new THREE.Vector3(1.0, 0.0, 0.0),  distance: PITCH, attachment: rotationY(Math.PI / 2.0) },   // +X (square face)
        1: {                                                                                                          // 45 degree slope
            direction: new THREE.Vector3(-1.0, 0.0, 1.0).normalize(),
            distance: SLOPE_DISTANCE,
            attachment: rotationY(-Math.PI / 4.0),  // child +Z ends up along the slope normal
        },
    },
    */
};
//--------------------

//
// shared lookup with a precise error message; every caller needs both
// checks, so they live in one place
function portGeometry(parentType, port) {
    const typeTable = PORT_GEOMETRY[parentType];

    if (!typeTable) {
        throw new Error(`Unknown parent cube type: ${parentType}`);
    }

    const geometry = typeTable[port];

    if (!geometry) {
        throw new Error(`Port ${port} does not exist on cube type ${parentType}.`);
    }

    return geometry;
}


/*
// converts detected orientation value into rotation matrix
// values: 0=0°, 1=90°, 2=180°, 3=270° around Z axis
export function orientationToTwist(orientation) {
    // % 4 is a safety guard: the firmware only sends 0-3, but if a
    // corrupt value ever slipped through, it would otherwise become a
    // silent >360° rotation instead of an obviously wrong pose
    const normalizedOrientation = orientation % 4;
    return rotationZ(normalizedOrientation * Math.PI / 2.0);
}

// converts detected orientation value into rotation matrix
// values: 0=90°, 1=180°, 2=270°, 3=0° around Z axis
export function orientationToTwist(orientation) {
    const normalizedOrientation = orientation % 4;

    return rotationZ(
        ((normalizedOrientation + 1) % 4) * Math.PI / 2.0
    );
}*/

// converts detected orientation value into rotation matrix
// values: 0=90°, 1=0°, 2=-90°, 3=-180° around Z axis
export function orientationToTwist(orientation) {
    const normalizedOrientation =
        ((orientation % 4) + 4) % 4;

    const angle =
        (1 - normalizedOrientation) * Math.PI / 2.0;

    return rotationZ(angle);
}

//calculates complete rotation of child cube: attachment rotation combined with twist rotation
export function childQuaternionForPort(port, orientation,parentType) {
    const attachmentQuaternion = portGeometry(parentType, port).attachment;

    if (!attachmentQuaternion) {
        throw new Error(`Unknown port: ${port}`);
    }

    const twistQuaternion = orientationToTwist(orientation);

    // combine the two rotations; ORDER MATTERS with quaternions:
    // attachment * twist = "first twist around own Z, then attach to
    // the port" (same order as the meshcat version:
    // child_rotation = attachment_rotation @ twist_rotation).
    // .clone() because multiply() modifies the left operand in place
    // and PORT_GEOMETRY must stay untouched for the next cube.
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
// position = port direction scaled to the port's distance, rotation =
// attachment + twist. parentType decides which port table applies -
// the same port number means a different face on a different cube type.
export function localPoseForChild(childNode,parentType) {
    if (childNode.port === null || childNode.port === undefined) {
        throw new Error(`Child cube ${childNode.id} has no port value.`);
    }

    const const geometry = portGeometry(parentType, childNode.port);


    // .clone() so the shared PORT_GEOMETRY vector is not modified
    const localPosition = geometry.direction.clone().multiplyScalar(geometry.distance);

    const localQuaternion = childQuaternionForPort(
        childNode.port,
        childNode.orientation,
        parentType
    );

    return {
        position: localPosition,
        quaternion: localQuaternion,
    };
}
