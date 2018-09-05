//
//  EffectSingleCropPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-11-30.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float left;
    float right;
    float bottom;
    float top;
};

fragment float4 effectSingleCropPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    u *= in.right - in.left;
    u += in.left;
    v *= in.top - in.bottom;
    v += in.bottom;
    
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}
