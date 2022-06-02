//
//  DepthCameraPIX.metal
//  PixelKit
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

struct Uniforms {
    float flipX;
};

fragment float4 depthCameraPIX(VertexOut out [[stage_in]],
                               texture2d<float>  inTex [[ texture(0) ]],
                               const device Uniforms& in [[ buffer(0) ]],
                               sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float4 c = inTex.sample(s, float2(v, in.flipX ? (1.0 - u) : u));
    
    return float4(c.r, c.r, c.r, c.a);
}


