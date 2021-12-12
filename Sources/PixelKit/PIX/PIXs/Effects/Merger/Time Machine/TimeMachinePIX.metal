//
//  EffectMergerTimeMachinePIX.metal
//  Pixel Nodes
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 effectMergerTimeMachinePIX(VertexOut out [[stage_in]],
                                           texture3d<float>  inTexTM [[ texture(0) ]],
                                           texture2d<float>  inTexB [[ texture(1) ]],
                                           sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 cb = inTexB.sample(s, uv);
    float lum = (cb.r + cb.g + cb.b) / 3;
    
    float4 ctm = inTexTM.sample(s, float3(u, v, lum));
    
    return ctm;
}
