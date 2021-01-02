//
//  EffectMultiBlendsPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 lerpColors(float4 fraction, float4 from, float4 to) {
    return from * (1.0 - fraction) + to * fraction;
}

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
    float4 c = 0;
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
            case 2: // Add Color
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 3: // Add
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c += ci;
                }
                break;
            case 4: // Mult
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c *= ci;
                }
                break;
            case 5: // Diff
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(abs(c_rgb - ci_rgb), max(c.a, ci.a));
                }
                break;
            case 6: // Sub Color
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb - ci_rgb, max(c.a, ci.a));
                }
                break;
            case 7: // Sub
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c -= ci;
                }
                break;
            case 8: // Max
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = max(c, ci);
                }
                break;
            case 9: // Min
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = min(c, ci);
                }
                break;
            case 10: // Gamma
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = pow(c, 1 / ci);
                }
                break;
            case 11: // Power
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c = pow(c, ci);
                }
                break;
            case 12: // Divide
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci;
                } else {
                    c /= ci;
                }
                break;
            case 13: // Average
                ci = inTexs.sample(s, uv, i);
                if (i == 0) {
                    c = ci / count;
                } else {
                    c += ci / count;
                }
                break;
        }
    }
    
    return c;
}
