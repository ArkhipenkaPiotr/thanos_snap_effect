#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6
#define fade_out_duration 0.3
#define particle_width 0.01
#define particle_height 0.08
#define particle_count (1 / particle_width) * (1 / particle_height)
#define particle_speed 1.0
#define min_movement_angle -2.2
#define max_movement_angle -0.76
#define movement_angles_count 10
#define movement_angle_step (max_movement_angle - min_movement_angle) / movement_angles_count
#define pi 3.14159265359

// Current animation value, from 0.0 to 1.0.
uniform float animationValue;
uniform vec2 uSize;
uniform sampler2D uImageTexture;

out vec4 fragColor;

float delayFromParticleCenterPos(float x)
{
    return (1. - particle_lifetime)*x;
}

float delayFromColumnIndex(int i)
{
    return (1. - particle_lifetime) * (i / (1 / particle_width));
}

float randomAngle(int i)
{
    float randomValue = fract(sin(float(i) * 12.9898 + 78.233) * 43758.5453);
    return min_movement_angle + floor(randomValue * movement_angles_count) * movement_angle_step;
}

int calculateInitialParticleIndex(vec2 point, float angle, float animationValue)
{
    //  x0 value is calculated from the following equation:

    //  x = x0 + t * cos(angle) * particle_speed
    //  t = animationValue - delay
    //  delay = (1 - particle_lifetime) * x0

    //  t = animationValue - (1 - particle_lifetime) * x0
    //  x = x0 + (animationValue - (1 - particle_lifetime) * x0) * cos(angle) * particle_speed
    //  x = x0 + animationValue * cos(angle) * particle_speed - (1 - particle_lifetime) * x0 * cos(angle) * particle_speed
    //  x = x0 - (1 - particle_lifetime) * x0 * cos(angle) * particle_speed + animationValue * cos(angle) * particle_speed
    //  x = x0 * (1 - (1 - particle_lifetime) * cos(angle) * particle_speed) + animationValue * cos(angle) * particle_speed
    //  x - animationValue * cos(angle) * particle_speed = x0 * (1 - (1 - particle_lifetime) * cos(angle) * particle_speed)
    //  x0 = (x - animationValue * cos(angle) * particle_speed) / (1 - (1 - particle_lifetime) * cos(angle) * particle_speed)

    float x0 = (point.x - animationValue * cos(angle) * particle_speed) / (1. - (1. - particle_lifetime) * cos(angle) * particle_speed);
    float delay = delayFromParticleCenterPos(x0);
    float y0 = point.y - (animationValue - delay) * sin(angle) * particle_speed;

    //  If particle is not yet moved, animationValue is less than delay, and particle moves to an opposite direction so we should calculate a particle index from the original point.

    // If the particle is supposed to move to the left, but it moves to the right (because of the reason above), return the original point particle index.
    if (angle <= - pi / 2 && point.x >= x0)
    {
        return (int(point.x / particle_width) + int(point.y / particle_height) * int(1 / particle_width));
    }
    // If the particle is supposed to move to the right, but it moves to the left (because of the reason above), return the original point particle index.
    if (angle >= - pi / 2 && point.x < x0)
    {
        return (int(point.x / particle_width) + int(point.y / particle_height) * int(1 / particle_width));
    }
    return int(x0 / particle_width) + int(y0 / particle_height) * int(1 / particle_width);
}

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    for (float searchMovementAngle = min_movement_angle; searchMovementAngle <= max_movement_angle; searchMovementAngle += movement_angle_step)
    {
        int i = calculateInitialParticleIndex(uv, searchMovementAngle, animationValue);
        if (i < 0 || i >= particle_count)
        {
            continue;
        }
        float angle = randomAngle(i);
//        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_width), int(float(i) / (1 / particle_width))) * particle_width + particle_width / 2;
        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_width) * particle_width + particle_width / 2, int(float(i) / (1 / particle_width)) * particle_height + particle_height / 2);
        float delay = delayFromParticleCenterPos(particleCenterPos.x);
        float adjustedTime = max(0.0, animationValue - delay);
        vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle) * particle_speed, uv.y - adjustedTime * sin(angle) * particle_speed);
        if (zeroPointPixelPos.x >= particleCenterPos.x - particle_width / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particle_width / 2 &&
        zeroPointPixelPos.y >= particleCenterPos.y - particle_height / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particle_height / 2)
        {
            vec4 zeroPointPixelColor = texture(uImageTexture, zeroPointPixelPos);
            float alpha = zeroPointPixelColor.a;
            float fadeOutLivetime = max(0.0, adjustedTime - (particle_lifetime - fade_out_duration));
            fragColor = zeroPointPixelColor * (1.0 - fadeOutLivetime / fade_out_duration);
            return;
        }
    }

    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}