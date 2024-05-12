#version 460 core

#include<flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uImageTexture;

out vec4 fragColor;

void main()
{
    vec2 uv=FlutterFragCoord().xy / uSize.xy;
    vec4 texColor=texture(uImageTexture, uv);

    fragColor = texColor / 2.0;
}
