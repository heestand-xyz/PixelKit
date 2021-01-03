//
//  EffectSingleChannelMixPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-12-06.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float rr;
    float rg;
    float rb;
    float ra;
    float gr;
    float gg;
    float gb;
    float ga;
    float br;
    float bg;
    float bb;
    float ba;
    float ar;
    float ag;
    float ab;
    float aa;
};

fragment float4 effectSingleChannelMixPIX(VertexOut out [[stage_in]],
                                            texture2d<float>  inTex [[ texture(0) ]],
                                            const device Uniforms& in [[ buffer(0) ]],
                                            sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    c = float4(
        c.r * in.rr + c.g * in.rg + c.b * in.rb + c.a * in.ra,
        c.r * in.gr + c.g * in.gg + c.b * in.gb + c.a * in.ga,
        c.r * in.br + c.g * in.bg + c.b * in.bb + c.a * in.ba,
        c.r * in.ar + c.g * in.ag + c.b * in.ab + c.a * in.aa
    );
    
    return c;
}
