#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 0.6

uniform vec2 uSize;
uniform sampler2D uImageTexture;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;

float randomMovementAngle(vec2 uv, float time)
{
    float randomValue = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = mix(0, 2 * 3.14, randomValue);
    return angle;
}

float calculateDelay(vec2 uv)
{
    return (1. - particle_lifetime)*(1 + uv.x - uv.y);
}

vec2 calculateZeroPointPixelPos(vec2 uv, float time)
{
    float delay = calculateDelay(uv);
    float adjustedTime = max(0.0, time - delay);

    float angle = randomMovementAngle(uv, adjustedTime);
    float x1 = uv.x;
    float y1 = uv.y;

    float x = (2*x1 - 1.25*pow(adjustedTime, 2) * cos(angle)) / (2 - 1.25*pow(adjustedTime, 2)*cos(angle)*(1 - tan(angle)));
    float y = (2*y1 - 1.25*pow(adjustedTime, 2) * sin(angle)) / (2 - 1.25*pow(adjustedTime, 2)*sin(angle)*(1/tan(angle) - 1));
    return vec2(uv.x - adjustedTime /2 * cos(angle), uv.y - adjustedTime /2 * sin(angle));
}

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;

    vec2 zeroPointPixelPos = calculateZeroPointPixelPos(uv, animationValue);
    if (zeroPointPixelPos.x < 0.0 || zeroPointPixelPos.x > 1.0 || zeroPointPixelPos.y < 0.0 || zeroPointPixelPos.y > 1.0)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        vec4 zeroPointPixelColor = texture(uImageTexture, zeroPointPixelPos);
        ////                float alpha = mix(zeroPointPixelColor.a, 0.0, animationValue);
        float particleDelay = calculateDelay(zeroPointPixelPos);
        if (animationValue - particleDelay < 0.0)
        {
            fragColor = zeroPointPixelColor;
        } else {
            float alpha = mix(zeroPointPixelColor.a, 0.0, (animationValue - particleDelay) / particle_lifetime);
            fragColor = vec4(zeroPointPixelColor.rgb, alpha);
        }
//                fragColor = zeroPointPixelColor;
    }
}
