#version 300 es
precision highp float;
precision mediump int;

uniform mat4 viewMatrix; // Supplied by ThreeJS
//uniform vec3 cameraPosition; // Supplied by ThreeJS

uniform samplerCube tEnv;
uniform sampler2D tData;
uniform int tonemapFlag;
uniform float exposure;

in vec3 vNormal;
in vec3 vPosition;
in vec2 vUv;

out vec4 fragColor;

#define saturate(a) clamp(a, 0.0, 1.0)
#define one_over_pi_by_2 0.63661977236
vec3 tonemap(vec3 color) {
    if (tonemapFlag == 0) return color;
    color *= exposure;
    return saturate(color);
}
void main() {
    vec3 viewDirection = normalize(vPosition);
    //vec3 viewDirection = normalize(vPosition-cameraPosition);
    vec3 N = normalize(vNormal);
    float incidentAngle = acos(dot(-viewDirection, N));
    float ct0 = dot(-viewDirection, N);
    vec3 reflectDirection = reflect(viewDirection, N);
    //vec3 reflectDirectionWorld = reflectDirection;
    
    mat3 cameraCoordinateMatrix = mat3(viewMatrix);
    vec3 reflectDirectionWorld = vec3(
    -dot(cameraCoordinateMatrix[0], reflectDirection),
    dot(cameraCoordinateMatrix[1], reflectDirection),
    dot(cameraCoordinateMatrix[2], reflectDirection)
    );
    vec3 vColor = texture(tEnv, reflectDirectionWorld).rgb * texture(tData, vec2(incidentAngle * one_over_pi_by_2, 0.5)).rgb;
    fragColor = vec4(tonemap(vColor * ct0), 1.);
}