//
//  ChannelReversePIX.metal
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2017-07-25.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

// Uniforms ?

fragment float4 channelReversePIX(VertexOut out [[stage_in]],
                                  texture2d<float>  inTex [[ texture(0) ]],
                                  sampler s [[ sampler(0) ]]) {

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return float4(c.b, c.g, c.r, c.a);
}
