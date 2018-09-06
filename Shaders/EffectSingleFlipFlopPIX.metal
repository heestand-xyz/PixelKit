//
//  EffectSingleFlipFlopPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-11-28.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float flip;
    float flop;
};

fragment float4 effectSingleFlipFlopPIX(VertexOut out [[stage_in]],
                                          texture2d<float> inTex [[ texture(0) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    if (in.flip == 1 || in.flip == 3) {
        u = 1.0 - u;
    }
    if (in.flip == 2 || in.flip == 3) {
        v = 1.0 - v;
    }
    
    float2 uv = float2(u, v);
    
    if (in.flop == 1) {
        uv = float2(1.0 - v, u);
    } else if (in.flop == 2) {
        uv = float2(v, 1.0 - u);
    }
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}
