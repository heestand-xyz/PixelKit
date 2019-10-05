//
//  EffectSingleSlicePIX.metal
//  VoxelKitShaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float axis;
    float fraction;
};

fragment float4 effectSingleSlicePIX(VertexOut out [[stage_in]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     texture3d<float>  inTex [[ texture(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float3 crd = 0.0;
    switch (int(in.axis)) {
        case 0: crd = float3(in.fraction, u, v);
        case 1: crd = float3(u, in.fraction, v);
        case 2: crd = float3(u, v, in.fraction);
    }
    
    float4 c = inTex.sample(s, crd);
    
    return c;
}

