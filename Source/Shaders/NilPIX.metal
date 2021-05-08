//
//  NilPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2018-07-31.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 nilPIX(VertexOut out [[stage_in]],
                       texture2d<float>  inTex [[ texture(0) ]],
                       sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}


