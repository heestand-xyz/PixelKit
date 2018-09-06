//
//  EffectSingleRangePIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-12-06.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float in_low;
    float in_high;
    float out_low;
    float out_high;
    float in_low_r;
    float in_low_g;
    float in_low_b;
    float in_low_a;
    float in_high_r;
    float in_high_g;
    float in_high_b;
    float in_high_a;
    float out_low_r;
    float out_low_g;
    float out_low_b;
    float out_low_a;
    float out_high_r;
    float out_high_g;
    float out_high_b;
    float out_high_a;
    float ignore_alpha;
};

fragment float4 effectSingleRangePIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float a = c.a;
    
    c = (c - in.in_low) / (in.in_high - in.in_low);
    c = float4(c.r, c.g, c.b, max(c.a, 1.0));
    c = in.out_low + c * (in.out_high - in.out_low);
    
    float4 in_low = float4(in.in_low_r, in.in_low_g, in.in_low_b, in.in_low_a);
    float4 in_high = float4(in.in_high_r, in.in_high_g, in.in_high_b, in.in_high_a);
    float4 out_low = float4(in.out_low_r, in.out_low_g, in.out_low_b, in.out_low_a);
    float4 out_high = float4(in.out_high_r, in.out_high_g, in.out_high_b, in.out_high_a);
    
    c = (c - in_low) / (in_high - in_low);
    c = float4(c.r, c.g, c.b, max(c.a, 1.0));
    c = out_low + c * (out_high - out_low);
    
    float4 no_a = float4(c.r, c.g, c.b, a);
    float4 pmp = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    
    float4 cc = in.ignore_alpha ? no_a : pmp;
    
    return cc;
}
