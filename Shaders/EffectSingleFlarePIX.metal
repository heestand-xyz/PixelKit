//
//  EffectSingleLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-07.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float scale;
    float count;
    float angle;
    float threshold;
    float brightness;
    float gamma;
    float cr;
    float cg;
    float cb;
    float ca;
    float rayRes;
    float aspect;
};
fragment float4 effectSingleFlarePIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float ang = in.angle * pi * 2;
    float thresh = in.threshold;
    float3 color = float3(in.cr, in.cg, in.cb);
    
    float flare = 0;
    for (int i = 0; i < in.count; i++) {
        float fi = float(i) / in.count;
        for (int j = 0; j < int(in.rayRes); j++) {
            float fj = float(j) / in.rayRes;
            float d = (fj - 0.5) * 2;
            float uj = cos(fi * pi * 2 + ang) * d * (in.scale / 10) / in.aspect;
            float vj = sin(fi * pi * 2 + ang) * d * (in.scale / 10);
            float2 uvj = float2(u + uj, v + vj);
            float4 q = inTex.sample(s, uvj);
            if (q.r > thresh && q.g > thresh && q.b > thresh) {
                flare += pow(1.0 - abs(d), 1.0 / in.gamma);
            }
        }
    }
    
    float3 light = float3(flare, flare, flare);
    light *= in.brightness;
    light *= color;
    
    return c + float4(light, 1.0);
}


