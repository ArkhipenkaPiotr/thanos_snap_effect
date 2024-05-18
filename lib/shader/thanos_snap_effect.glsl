#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime 1.0

uniform vec2 uSize;
uniform sampler2D uImageTexture;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;

float randomMovementAngle(vec2 uv, float time)
{
    return -fract(sin(15.234756823656528 * uv.x / uv.y) * 1360.234) * 4.14;
}

vec2 calculateZeroPointPixelPos(vec2 uv, float time)
{
    float angle = randomMovementAngle(uv, time);
    float accelerationFactor = pow(mix(1.0, 0.0, uv.x), 1.0);
//    float accelerationFactor = 1.0;

    return vec2(uv.x - time * cos(angle) * accelerationFactor, uv.y - time * sin(angle) * accelerationFactor);
}

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;
    vec4 texColor=texture(uImageTexture, uv);

    vec2 zeroPointPixelPos = calculateZeroPointPixelPos(uv, animationValue);
    if (zeroPointPixelPos.x < 0.0 || zeroPointPixelPos.x > 1.0 || zeroPointPixelPos.y < 0.0 || zeroPointPixelPos.y > 1.0)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        vec4 zeroPointPixelColor = texture(uImageTexture, zeroPointPixelPos);
//        float alpha = mix(zeroPointPixelColor.a, 0.0, animationValue);
        float alpha = zeroPointPixelColor.a;
        fragColor = vec4(zeroPointPixelColor.rgb, alpha);
    }
}
