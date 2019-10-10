//
//  EffectSingleAveragePIX.metal
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
};

fragment float4 effectSingleAveragePIX(VertexOut out [[stage_in]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       texture3d<float>  inTex [[ texture(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    int res = 0;
    switch (int(in.axis)) {
        case 0: res = inTex.get_width(); break;
        case 1: res = inTex.get_height(); break;
        case 2: res = inTex.get_depth(); break;
    }
    
    float4 c = 0.0;
    for (int i = 0; i < res; ++i) {
        
        float fraction = (float(i) + 0.5) / float(res);
       
        float3 crd = 0.0;
        switch (int(in.axis)) {
            case 0: crd = float3(fraction, u, v); break;
            case 1: crd = float3(u, fraction, v); break;
            case 2: crd = float3(u, v, fraction); break;
        }
        
        c += inTex.sample(s, crd);
        
    }
    c /= float(res);
    
    return c;
}

