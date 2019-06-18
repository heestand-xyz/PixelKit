//
//  EffectMultiBlendsPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-10.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Hardcoded at 128
// Defined as uniformArrayMaxLimit in source
constant int ARRMAX = 128;

float4 lerpColorsB(float4 fraction, float4 from, float4 to) {
    return from * (1.0 - fraction) + to * fraction;
}

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float mode;
    float count;
    float br;
    float bg;
    float bb;
    float ba;
    float aspect;
};

struct Coord {
    float x;
    float y;
    float scl;
    float rot;
    float index;
};

fragment float4 effectMultiArrayPIX(VertexOut out [[stage_in]],
                                    texture2d_array<float>  inTexs [[ texture(0) ]],
                                    const device Uniforms& in [[ buffer(0) ]],
                                    const device array<Coord, ARRMAX>& inArr [[ buffer(1) ]],
                                    const device array<bool, ARRMAX>& inArrActive [[ buffer(2) ]],
                                    sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    int count = in.count;
    if (count > ARRMAX) {
        count = ARRMAX;
    }
    
    int texCount = inTexs.get_array_size();
    
    float4 c = 0;
    float4 ci;
    for (int j = 0; j < count; ++j) {
        
        float2 pos = float2(inArr[j].x, inArr[j].y);
        float scl = inArr[j].scl;
        float rot = inArr[j].rot * pi * 2;
        
        int i = int(inArr[j].index);
        if (i < 0) {
            i = 0;
        } else if (i > texCount - 1) {
            i = texCount - 1;
        }

        float ang = atan2(v - 0.5 + pos.y, (u - 0.5) * in.aspect - pos.x) - rot;
        float amp = sqrt(pow((u - 0.5) * in.aspect - pos.x, 2) + pow(v - 0.5 + pos.y, 2));
        float2 juv = float2((cos(ang) / in.aspect) * amp, sin(ang) * amp) / scl + 0.5;

        // Blend
        uint ir = texCount - i - 1;
        switch (int(in.mode)) {
            case 0: // Over
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 1: // Under
                ci = inTexs.sample(s, juv, ir);
                if (j == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb * (1.0 - ci.a) + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 2: // Add Color
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb + ci_rgb, max(c.a, ci.a));
                }
                break;
            case 3: // Add
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c += ci;
                }
                break;
            case 4: // Mult
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c *= ci;
                }
                break;
            case 5: // Diff
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(abs(c_rgb - ci_rgb), max(c.a, ci.a));
                }
                break;
            case 6: // Sub Color
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    float3 c_rgb = float3(c);
                    float3 ci_rgb = float3(ci);
                    c = float4(c_rgb - ci_rgb, max(c.a, ci.a));
                }
                break;
            case 7: // Sub
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c -= ci;
                }
                break;
            case 8: // Max
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c = max(c, ci);
                }
                break;
            case 9: // Min
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c = min(c, ci);
                }
                break;
            case 10: // Gamma
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c = pow(c, 1 / ci);
                }
                break;
            case 11: // Power
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c = pow(c, ci);
                }
                break;
            case 12: // Divide
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci;
                } else {
                    c /= ci;
                }
                break;
            case 13: // Average
                ci = inTexs.sample(s, juv, i);
                if (j == 0) {
                    c = ci / count;
                } else {
                    c += ci / count;
                }
                break;
        }
        
    }
    
    float4 cb = float4(in.br, in.bg, in.bb, in.ba);
    float4 o = float4(cb.rgb * (1.0 - c.a) + c.rgb, max(cb.a, c.a));
    
    return o;
}
