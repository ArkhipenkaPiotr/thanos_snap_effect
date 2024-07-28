#version 460 core

#include<flutter/runtime_effect.glsl>

#define min_movement_angle -2.2
#define max_movement_angle -0.76
#define movement_angles_count 10
#define movement_angle_step (max_movement_angle - min_movement_angle) / movement_angles_count
#define pi 3.14159265359

// Current animation value, from 0.0 to 1.0.
uniform float animationValue;
uniform float particleLifetime;
uniform float fadeOutDuration;
uniform float particleWidth;
uniform float particleHeight;
uniform float particleSpeed;
uniform vec2 uSize;
uniform sampler2D uImageTexture;

out vec4 fragColor;

float delayFromParticleCenterPos(float x)
{
    return (1. - particleLifetime)*x;
}

float delayFromColumnIndex(int i)
{
    return (1. - particleLifetime) * (i / (1 / particleWidth));
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

    float x0 = (point.x - animationValue * cos(angle) * particleSpeed) / (1. - (1. - particleLifetime) * cos(angle) * particleSpeed);
    float delay = delayFromParticleCenterPos(x0);
    float y0 = point.y - (animationValue - delay) * sin(angle) * particleSpeed;

    //  If particle is not yet moved, animationValue is less than delay, and particle moves to an opposite direction so we should calculate a particle index from the original point.

    // If the particle is supposed to move to the left, but it moves to the right (because of the reason above), return the original point particle index.
    if (angle <= - pi / 2 && point.x >= x0)
    {
        return (int(point.x / particleWidth) + int(point.y / particleHeight) * int(1 / particleWidth));
    }
    // If the particle is supposed to move to the right, but it moves to the left (because of the reason above), return the original point particle index.
    if (angle >= - pi / 2 && point.x < x0)
    {
        return (int(point.x / particleWidth) + int(point.y / particleHeight) * int(1 / particleWidth));
    }
    return int(x0 / particleWidth) + int(y0 / particleHeight) * int(1 / particleWidth);
}

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    float particlesCount = (1 / particleWidth) * (1 / particleHeight);
    for (float searchMovementAngle = min_movement_angle; searchMovementAngle <= max_movement_angle; searchMovementAngle += movement_angle_step)
    {
        int i = calculateInitialParticleIndex(uv, searchMovementAngle, animationValue);
        if (i < 0 || i >= particlesCount)
        {
            continue;
        }
        float angle = randomAngle(i);
//        vec2 particleCenterPos = vec2(mod(float(i), 1 / particle_width), int(float(i) / (1 / particle_width))) * particle_width + particle_width / 2;
        vec2 particleCenterPos = vec2(mod(float(i), 1 / particleWidth) * particleWidth + particleWidth / 2, int(float(i) / (1 / particleWidth)) * particleHeight + particleHeight / 2);
        float delay = delayFromParticleCenterPos(particleCenterPos.x);
        float adjustedTime = max(0.0, animationValue - delay);
        vec2 zeroPointPixelPos = vec2(uv.x - adjustedTime * cos(angle) * particleSpeed, uv.y - adjustedTime * sin(angle) * particleSpeed);
        if (zeroPointPixelPos.x >= particleCenterPos.x - particleWidth / 2 && zeroPointPixelPos.x <= particleCenterPos.x + particleWidth / 2 &&
        zeroPointPixelPos.y >= particleCenterPos.y - particleHeight / 2 && zeroPointPixelPos.y <= particleCenterPos.y + particleHeight / 2)
        {
            vec4 zeroPointPixelColor = texture(uImageTexture, zeroPointPixelPos);
            float alpha = zeroPointPixelColor.a;
            float fadeOutLivetime = max(0.0, adjustedTime - (particleLifetime - fadeOutDuration));
            fragColor = zeroPointPixelColor * (1.0 - fadeOutLivetime / fadeOutDuration);
            return;
        }
    }

    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
}