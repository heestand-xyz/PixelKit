//
//  ContentResourceImagePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2018-07-31.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float tint;
    float fg_r;
    float fg_g;
    float fg_b;
    float fg_a;
    float bg_r;
    float bg_g;
    float bg_b;
    float bg_a;
    float flip;
    float swizzle;
};

fragment float4 contentResourceImagePIX(VertexOut out [[stage_in]],
                                        texture2d<float>  inTex [[ texture(0) ]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.flip) {
        v = 1 - v; // Content Flip Fix
    }
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    if (in.swizzle) {
        c = float4(c.b, c.g, c.r, c.a); // BGRA
    }
    
    float4 bg = float4(in.bg_r, in.bg_g, in.bg_b, in.bg_a);
    
    if (in.tint) {
        float4 fg = float4(in.fg_r, in.fg_g, in.fg_b, in.fg_a);
        return bg * (1. - c.a) + fg * c.a;
    }
    
    if (c.a < 1. && bg.a > 0.) {
        c = float4(bg.rgb * (1. - c.a) + c.rgb, max(c.a, bg.a));
    }
    
    return float4(c.b, c.g, c.r, c.a);
}


