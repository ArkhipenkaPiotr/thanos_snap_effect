#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.04

uniform vec2 uSize;
uniform sampler2D uImageTexture;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;

float calculateDelay(vec2 uv)
{
    return (1. - particle_lifetime)*(1 + uv.x - uv.y) / 2;
}

float randomAngle(int i)
{
    float randomValue = fract(sin(float(i) * 12.9898 + 78.233) * 43758.5453);
    return mix(-0.76, -2.2, randomValue);
}


void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    for (int i = 0; i < int(pow(1 / particle_size, 2)); i++)
    {
        float angle = randomAngle(i);
        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_size), int(float(i) / (1 / particle_size))) * particle_size + particle_size / 2;
        float delay = calculateDelay(particleCenterPos);
        float adjustedTime = max(0.0, animationValue - delay);
        vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle), uv.y - adjustedTime * sin(angle));
        if (zeroPointPixelPos.x >= particleCenterPos.x - particle_size / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particle_size / 2 &&
        zeroPointPixelPos.y >= particleCenterPos.y - particle_size / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particle_size / 2)
        {
            fragColor = texture(uImageTexture, zeroPointPixelPos);
            return;
        }
    }
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}