//
//  EffectMultiBlendsPIX.metal
//  Pixels Shaders
//
//  Created by Hexagons on 2017-11-10.
//  Copyright © 2017 Hexagons. All rights reserved.
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

fragment float4 effectMultiBlendsPIX(VertexOut out [[stage_in]],
                                      texture2d_array<float>  inTexs [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint count = inTexs.get_array_size();
    
    // Blend
    float4 c;
    float4 ci;
    for (uint i = 0; i < count; ++i) {
        uint ir = count - i - 1;
        switch (int(in.mode)) {
            case 0: // Over
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 1: // Under
                ci = inTexs.sample(s, uv, ir);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 2: // Add
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 3: // Mult
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * ci_rgb, max(c.a, ci.a));
                }
                break;
            case 4: // Diff
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(abs(c_rgb - ci_rgb), max(c.a, ci.a));
                }
                break;
            case 5: // Sub
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb - ci_rgb, max(c.a, ci.a));
                }
                break;
            case 6: // Max
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(max(c_rgb, ci_rgb), max(c.a, ci.a));
                }
                break;
            case 7: // Min
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(min(c_rgb, ci_rgb), max(c.a, ci.a));
                }
                break;
        }
    }
    
    return c;
}
