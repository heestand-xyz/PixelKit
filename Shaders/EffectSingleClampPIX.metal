//
//  EffectSingleClampPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2019-04-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float low;
    float high;
    float clampAlpha;
};

fragment float4 effectSingleClampPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float r = c.r;
    if (r < in.low) {
        r = in.low;
    } else if (r > in.high) {
        r = in.high;
    }
    
    float g = c.g;
    if (g < in.low) {
        g = in.low;
    } else if (g > in.high) {
        g = in.high;
    }
    
    float b = c.b;
    if (b < in.low) {
        b = in.low;
    } else if (b > in.high) {
        b = in.high;
    }
    
    float a = c.a;
    if (in.clampAlpha) {
        if (a < in.low) {
            a = in.low;
        } else if (a > in.high) {
            a = in.high;
        }
    }
    
    return float4(r, g, b, c.a);
}


