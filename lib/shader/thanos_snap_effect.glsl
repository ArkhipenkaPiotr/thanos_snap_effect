#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define particle_size 0.01
#define min_movement_angle -2.2
#define max_movement_angle -0.76
#define movement_angles_count 10
#define movement_angle_step (max_movement_angle - min_movement_angle) / movement_angles_count

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
    return min_movement_angle + floor(randomValue * movement_angles_count) * movement_angle_step;
}


void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    for (float searchMovementAngle = min_movement_angle; searchMovementAngle <= max_movement_angle; searchMovementAngle += movement_angle_step)
    {
        vec2 searchPoint = vec2(uv.x - animationValue * cos(searchMovementAngle), uv.y - animationValue * sin(searchMovementAngle));
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

    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}