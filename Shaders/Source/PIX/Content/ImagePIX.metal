//
//  NilPIX.metal
//  HxPxE
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 imagePIX(VertexOut out [[stage_in]],
                         texture2d<float>  inTex [[ texture(0) ]],
                         sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}


