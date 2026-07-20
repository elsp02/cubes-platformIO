// scene_environment.js - shared scene surroundings for ALL tree views:
// background color, lights and the shadow-catching ground plane.

import * as THREE from "three";

// one place for the background color of all tree views
export const SCENE_BACKGROUND_COLOR = 0xb9b9b9;

// how dark the cube shadows appear on the ground (0 = invisible, 1 = black)
const SHADOW_OPACITY = 0.1;

// Adds background + lights + ground to the scene.
export function addSceneEnvironment(scene) {
    scene.background = new THREE.Color(SCENE_BACKGROUND_COLOR);

    // illuminates every surface equally from all directions, flat base brightness
    scene.add(new THREE.AmbientLight(0xffffff, 0.7));

    // simulates rays from an infinitely distant source (like the sun);
    // position = direction the rays come FROM: above and diagonally in
    // front, so every visible face gets some light and the shadow falls
    // behind the construction
    const topLight = new THREE.DirectionalLight(0xffffff, 1.5);
    topLight.position.set(4, -5, 8);
    topLight.castShadow = true;
    scene.add(topLight);

    // ShadowMaterial ->plane itself is invisible, only the received shadows are drawn 
    const ground = new THREE.Mesh(
        new THREE.PlaneGeometry(1000, 1000),
        new THREE.ShadowMaterial({ opacity: SHADOW_OPACITY })
    );
    ground.receiveShadow = true;
    scene.add(ground);

    return { ground, topLight };
}

// top of the ground plane exactly at the bottom of the construction
export function placeGroundUnderBox(ground, box) {
    ground.position.z = box.min.z - 0.001;
}
