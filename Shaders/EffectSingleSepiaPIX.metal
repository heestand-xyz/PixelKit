//
//  EffectSingleLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-07.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 lerp(float fraction, float4 from, float4 to) {
    return from * (1.0 - fraction) + to * fraction;
}

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float r;
    float g;
    float b;
    float a;
};
fragment float4 effectSingleSepiaPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    float lum = (c.r + c.g + c.b) / 3;
    
    float4 b = float4(0.0, 0.0, 0.0, 1.0);
    float4 w = float4(1.0, 1.0, 1.0, 1.0);
    
    float4 inc = float4(in.r / 2, in.g / 2, in.b / 2, in.a);
    
    float4 sepia;
    if (lum < 0.5) {
        sepia = lerp(min(lum * 2, 1.0), b, inc);
    } else {
        sepia = lerp(max(lum * 2 - 1, 0.0), inc, w);
    }
    
    return sepia;
}


