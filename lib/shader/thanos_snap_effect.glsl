#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.04
#define particles_in_row 1 / particle_size
#define particles_count particles_in_row * particles_in_row

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
    float randomValue = mod(sin(i) * 150, 1);
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
//    int i = int(indexNumber.r * 256.0 * 256.0 * 256.0 * 256.0 + indexNumber.g * 256.0 * 256.0 * 256.0 + indexNumber.b * 256.0 * 256.0 + indexNumber.a * 256.0);

    float rDex = indexNumber.r * 255.0 * 256.0 * 256.0 * 256.0;
    float gDex = indexNumber.g * 255.0 * 256.0 * 256.0;
    float bDex = indexNumber.b * 255.0 * 256.0;
    float aDex = indexNumber.a * 255.0;
    float floatIndex = rDex + gDex + bDex + aDex;
    int intIndex = int(rDex) + int(gDex) + int(bDex) + int(aDex);
//        fragColor = vec4(mod(floatIndex, 2), mod(floatIndex, 2), mod(floatIndex, 2), 255);
//        fragColor = vec4(mod(intIndex∂, 2), mod(intIndex, 2), mod(intIndex, 2), 255);
//        fragColor = vec4(mod(bDex, 2), mod(bDex, 2), mod(bDex, 2), 255);
//        fragColor = vec4(mod(aDex, 2), mod(aDex, 2), mod(aDex, 2), 255);

    int i = intIndex;
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
//        if (zeroPointPixelPos.x >= particleCenterPos.x - particle_size / 6 && zeroPointPixelPos.x <= particleCenterPos.x + particle_size / 6 &&
//        zeroPointPixelPos.y >= particleCenterPos.y - particle_size / 6 && zeroPointPixelPos.y <= particleCenterPos.y + particle_size / 6)
//        {
//            fragColor = vec4(0, 1, 0, 1);
//            return;
//        }

        fragColor = texture(uImageTexture, zeroPointPixelPos);
        return;
    }
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);

//        fragColor = texture(uImageTexture, zeroPointPixelPos);
}