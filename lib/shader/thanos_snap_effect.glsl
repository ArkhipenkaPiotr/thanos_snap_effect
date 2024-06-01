#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.026

uniform vec2 uSize;
uniform sampler2D uImageTexture;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;
float randomMovementAngle(vec2 uv, float time)
{
    vec2 normalizedPosition = floor(uv / particle_size) * particle_size;
    float randomValue = fract(sin(dot(normalizedPosition, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = mix(0, -3.14, randomValue);
    return angle;
}

float calculateDelay(vec2 uv)
{
    return (1. - particle_lifetime)*(1 + uv.x - uv.y) / 2;
}

vec2 calculateZeroPointPixelPos(vec2 uv, float time)
{
    float delay = calculateDelay(uv);
    float adjustedTime = max(0.0, time - delay);

    float angle = randomMovementAngle(uv, adjustedTime);
    float x1 = uv.x;
    float y1 = uv.y;

    return vec2(uv.x - adjustedTime /2 * cos(angle), uv.y - adjustedTime /2 * sin(angle));
}

float powerInterpolation(float v0, float v1, float t, float p) {
    return (1 - pow(t, p)) * v0 + pow(t, p) * v1;
}

float randomAngle(int i)
{
    float randomValue = fract(sin(float(i) * 12.9898 + 78.233) * 43758.5453);
    return mix(0, -3.14, randomValue);
}


void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    for (int i = 0; i < int(pow(1 / particle_size, 2)); i++)
    {
        float angle = randomAngle(i);
        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_size), float(i) / (1 / particle_size)) * particle_size;
        vec2 zeroPointPixelPos = vec2(uv.x - animationValue * cos(angle), uv.y - animationValue * sin(angle));
        if (distance(particleCenterPos, zeroPointPixelPos) < particle_size / 2)
        {
            fragColor = texture(uImageTexture, zeroPointPixelPos);
            return;
        }
    }
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
//    vec2 zeroPointPixelPos = calculateZeroPointPixelPos(uv, animationValue);
//    if (zeroPointPixelPos.x < 0.0 || zeroPointPixelPos.x > 1.0 || zeroPointPixelPos.y < 0.0 || zeroPointPixelPos.y > 1.0)
//    {
//        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
//    } else {
//        vec4 zeroPointPixelColor = texture(uImageTexture, zeroPointPixelPos);
//        float particleDelay = calculateDelay(zeroPointPixelPos);
//        if (animationValue - particleDelay < 0.0)
//        {
//            fragColor = zeroPointPixelColor;
//        } else {
//            float alpha = powerInterpolation(zeroPointPixelColor.a, 0.0, (animationValue - particleDelay) / particle_lifetime, 2);
//            fragColor = vec4(zeroPointPixelColor.rgb, alpha);
//        }
//    }
}