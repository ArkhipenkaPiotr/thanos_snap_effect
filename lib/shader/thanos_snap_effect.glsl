#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.02
#define particles_in_row 1 / particle_size

uniform vec2 uSize;
uniform sampler2D uImageTexture;
uniform sampler2D uParticlesMap;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;

float calculateDelay(vec2 uv)
{
    return (1. - particle_lifetime)*(1 + uv.x - uv.y) / 2;
}

float randomAngle(int i)
{
    float randomValue = mod(sin(i * 12.9898 + 78.233) * 43758.5453, 1);
    return (-2.2) * (1 - randomValue) + (-0.76) * randomValue;
//    return -2.2;
}

vec2 particleInitialPosition(int particleIndex)
{
    float columnNumber = mod(particleIndex, particles_in_row) * particle_size;
    float particleWidth = particle_size;
    float x = (columnNumber / particles_in_row) + particleWidth / 2;

    float particleHeight = particle_size;
    int rowNumber = int(particleIndex / particles_in_row);
    float y = (rowNumber / particles_in_row) + particleHeight / 2;
    return vec2(x, y);
}

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    vec4 indexNumber = texture(uParticlesMap, uv);
    int i = int(indexNumber.r * 256 * 256 * 256 * 256 + indexNumber.g * 256 * 256 * 256 + indexNumber.b * 256 * 256 + indexNumber.a * 256);

    //    fragColor = vec4(mod(indexNumber.a, 256), mod(indexNumber.a, 256), mod(indexNumber.a, 256), 255);
    float angle = randomAngle(i);
    vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_size), int(float(i) / (1 / particle_size))) * particle_size + particle_size / 2;
//    vec2 particleCenterPos = particleInitialPosition(i);
    float delay = calculateDelay(particleCenterPos);
    //    float adjustedTime = max(0.0, animationValue - delay);
    float adjustedTime = max(0.0, animationValue);
    vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle), uv.y - adjustedTime * sin(angle));
    if (zeroPointPixelPos.x >= particleCenterPos.x - particle_size / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particle_size / 2 &&
    zeroPointPixelPos.y >= particleCenterPos.y - particle_size / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particle_size / 2)
    {
        fragColor = texture(uImageTexture, zeroPointPixelPos);
        return;
    }
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);

//        fragColor = texture(uImageTexture, zeroPointPixelPos);
}