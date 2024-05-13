#version 460 core

#include<flutter/runtime_effect.glsl>

#define particle_lifetime .5

uniform vec2 uSize;
uniform sampler2D uImageTexture;
// Current animation value, from 0.0 to 1.0.
uniform float animationValue;

out vec4 fragColor;

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;
    vec4 texColor=texture(uImageTexture, uv);

    float distanceFactor = distance(uv, vec2(0.0, 1.0));
    float alpha = (particle_lifetime + distanceFactor * (1.0 - particle_lifetime) - animationValue) / (particle_lifetime);

    fragColor = vec4(texColor.rgb, texColor.a * alpha);
}
