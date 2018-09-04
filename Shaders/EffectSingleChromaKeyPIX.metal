//
//  EffectSingleChromaKeyPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-12-15.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float key_r;
    float key_g;
    float key_b;
    float key_a;
    float range;
    float softness;
    float edge_desat;
    float premultiply;
};

fragment float4 effectSingleChromaKeyPIX(VertexOut out [[stage_in]],
                                           texture2d<float>  inTex [[ texture(0) ]],
                                           const device Uniforms& in [[ buffer(0) ]],
                                           sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float3 ck_hsv = rgb2hsv(in.key_r, in.key_g, in.key_b);
    
    float4 c = inTex.sample(s, uv);
    
    float3 c_hsv = rgb2hsv(c.r, c.g, c.b);
    
    float ck_h = abs(c_hsv[0] - ck_hsv[0]) - in.range;
    
    float ck = (ck_h + (in.softness) / 2) / in.softness;
    if (ck < 0.0) {
        ck = 0.0;
    } else if (ck > 1.0) {
        ck = 1.0;
    }
    
    ck = max(ck, 1.0 - c_hsv[1]);

    float edge_sat = 1 - in.edge_desat;
    if (edge_sat < 0) { edge_sat = 0; }
    else if (edge_sat > 1) { edge_sat = 1; }
    c_hsv[1] *= mix(edge_sat, 1.0, pow(ck, 10));
    
    float3 ck_c = hsv2rgb(c_hsv[0], c_hsv[1], c_hsv[2]);
    
    if (in.premultiply) {
        ck_c *= ck;
    }
    
    return float4(ck_c.r, ck_c.g, ck_c.b, ck);
}
