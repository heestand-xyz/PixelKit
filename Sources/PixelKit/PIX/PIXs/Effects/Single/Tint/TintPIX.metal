//
//  EffectSingleLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-07.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float r;
    float g;
    float b;
    float a;
};
fragment float4 effectSingleTintPIX(VertexOut out [[stage_in]],
                                    texture2d<float>  inTex [[ texture(0) ]],
                                    const device Uniforms& in [[ buffer(0) ]],
                                    sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float4 tint = float4(in.r, in.g, in.b, in.a);
    
    return c * tint;
}


