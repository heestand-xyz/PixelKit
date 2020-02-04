//
//  ContentResourceBackgroundPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2020-02-04.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float bgR;
    float bgG;
    float bgB;
    float bgA;
    float flip;
};

fragment float4 contentResourceBackgroundPIX(VertexOut out [[stage_in]],
                                             texture2d<float>  inTex [[ texture(0) ]],
                                             const device Uniforms& in [[ buffer(0) ]],
                                             sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.flip > 0.0) {
        v = 1 - v; // Content Flip Fix
    }
    float2 uv = float2(u, v);
    
    float4 bg = float4(in.bgR, in.bgG, in.bgB, in.bgA);
    float4 c = inTex.sample(s, uv);
    float4 bgc = float4(bg.rgb * (1.0 - c.a) + c.rgb * c.a, max(c.a, bg.a));

    return bgc;
}


