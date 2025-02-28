#version 300 es
precision highp float;
precision mediump int;

uniform mat4 modelViewMatrix; // Supplied by ThreeJS
uniform mat4 projectionMatrix; // Supplied by ThreeJS
uniform mat3 normalMatrix;// Supplied by ThreeJS
//uniform mat4 modelMatrix;

in vec3 position;
in vec3 normal;
in vec2 uv;

out vec3 vNormal;
out vec3 vPosition;
out vec2 vUv;

void main() {
    vUv = uv;
    vNormal = normalize(normalMatrix * normal);
    vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
    //vNormal = normalize(mat3(modelMatrix)*normal);
    //vPosition = (modelMatrix*vec4( position, 1.0 )).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}