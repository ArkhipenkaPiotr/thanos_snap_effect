#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.01
#define min_movement_angle -2.2
#define max_movement_angle -0.76

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
    return mix(min_movement_angle, max_movement_angle, randomValue);
}


void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    for (float reverseAngle = -max_movement_angle; reverseAngle < -min_movement_angle; reverseAngle += 0.01)
    {
        vec2 searchPoint = vec2(uv.x + animationValue * cos(reverseAngle), uv.y + animationValue * sin(reverseAngle));
        int i = int(searchPoint.x / particle_size) + int(searchPoint.y / particle_size) * int(1 / particle_size);

        if (i < 0 || i >= int(pow(1 / particle_size, 2)))
        {
            continue;
        }
        float angle = randomAngle(i);
        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_size), int(float(i) / (1 / particle_size))) * particle_size + particle_size / 2;
        float delay = calculateDelay(particleCenterPos);
        float adjustedTime = max(0.0, animationValue);
        vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle), uv.y - adjustedTime * sin(angle));
        if (zeroPointPixelPos.x >= particleCenterPos.x - particle_size / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particle_size / 2 &&
        zeroPointPixelPos.y >= particleCenterPos.y - particle_size / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particle_size / 2)
        {
            fragColor = texture(uImageTexture, zeroPointPixelPos);
            return;
        }
    }

    //    for (int i = 0; i < int(pow(1 / particle_size, 2)); i++)
    //    {
    //        float angle = randomAngle(i);
    //        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_size), int(float(i) / (1 / particle_size))) * particle_size + particle_size / 2;
    //        float delay = calculateDelay(particleCenterPos);
    //        float adjustedTime = max(0.0, animationValue);
    //        vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle), uv.y - adjustedTime * sin(angle));
    //        if (zeroPointPixelPos.x >= particleCenterPos.x - particle_size / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particle_size / 2 &&
    //        zeroPointPixelPos.y >= particleCenterPos.y - particle_size / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particle_size / 2)
    //        {
    //            fragColor = texture(uImageTexture, zeroPointPixelPos);
    //            return;
    //        }
    //    }
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}