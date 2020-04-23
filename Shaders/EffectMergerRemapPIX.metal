//
//  EffectMergerRemapPIX.metal
//  PixelKitShaders
//
//  Created by Hexagons on 2017-12-06.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 effectMergerRemapPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTexA [[ texture(0) ]],
                                      texture2d<float>  inTexB [[ texture(1) ]],
                                      sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 cb = inTexB.sample(s, uv);

    float2 uv_map = float2(cb.r, 1.0 - cb.g); // Content Flip Fix
    
    float4 ca = inTexA.sample(s, uv_map) * cb.a;
    
    return ca;
}
