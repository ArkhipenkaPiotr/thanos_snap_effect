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
    float randomValue = fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
    float angle = mix(-3.14159, 0.0, randomValue);
    return angle;
}
vec2 calculateZeroPointPixelPos(vec2 uv, float time)
{
    float angle = randomMovementAngle(uv, time);
    //    float accelerationFactor = pow(mix(1.0, 0.0, uv.x), 1.0);
    ////    float accelerationFactor = 1.0;
    //
    //    return vec2(uv.x - time * cos(angle) * accelerationFactor, uv.y - time * sin(angle) * accelerationFactor);
    float x1 = uv.x;
    float y1 = uv.y;

    float x = (2*x1 - 1.25*pow(time, 2) * cos(angle)) / (2 - 1.25*pow(time, 2)*cos(angle)*(1 - tan(angle)));
    float y = (2*y1 - 1.25*pow(time, 2) * sin(angle)) / (2 - 1.25*pow(time, 2)*sin(angle)*(1/tan(angle) - 1));
    return vec2(x, y);
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
//                float alpha = mix(zeroPointPixelColor.a, 0.0, animationValue);
        float alpha = zeroPointPixelColor.a;
        fragColor = vec4(zeroPointPixelColor.rgb, alpha);
    }
}
