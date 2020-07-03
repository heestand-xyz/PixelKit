//
//  EffectSingleReducePIX.metal
//  VoxelKitShaders
//
//  Created by Anton Heestand on 2020-07-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float isAvg;
    float count;
};

fragment float4 effectSingleReducePIX(VertexOut out [[stage_in]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    if (in.isAvg) {
        c /= float(in.count);
    }
    
    return c;
}

