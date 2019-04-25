//
//  EffectSingleConvertPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2019-04-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float mode;
};

fragment float4 effectSingleConvertPIX(VertexOut out [[stage_in]],
                                       texture2d<float>  inTex [[ texture(0) ]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
//    v = 1 - v; // Content Flip Fix A
    float2 uv = float2(u, v);
    
    float er = v;
    float ea = u * pi * 2;
    
//    float radius = 0.5;
//
//    float theta = u;
//    float phi = v;
//
//    float x = cos(theta) * cos(phi) * radius;
//    float y = sin(theta) * cos(phi) * radius;
//    float z = sin(phi) * radius;
    
    float dr = sqrt(pow(u - 0.5, 2) + pow(v, 2)) + 0.5;
    float da = atan2(v, u - 0.5) / (pi * 2);
    dr = dr - floor(dr);
    da = da - floor(da);

    switch (int(in.mode)) {
        case 0: // Equirectangular
            uv = float2(0.5 + cos(ea) * er, 0.5 + sin(ea) * er);
            break;
        case 1: // Dome
            uv = float2(dr, da);
            break;
    }
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}
