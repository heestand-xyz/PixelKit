//
//  EffectMergerLumaRainbowBlurPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../Shaders/Source/Effects/hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float type;
    float radius;
    float res;
    float angle;
    float x;
    float y;
    float light;
};

fragment float4 effectMergerLumaRainbowBlurPIX(VertexOut out [[stage_in]],
                                               texture2d<float>  inTexA [[ texture(0) ]],
                                               texture2d<float>  inTexB [[ texture(1) ]],
                                               const device Uniforms& in [[ buffer(0) ]],
                                               sampler s [[ sampler(0) ]]) {
    
    float pi = M_1_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
        
    float4 cb = inTexB.sample(s, uv);
    
    float lum = (cb.r + cb.g + cb.b) / 3;
    
    uint w = inTexA.get_width();
    uint h = inTexA.get_height();
    float aspect = w / h;
    
    int res = int(in.res);
    
    float angle = in.angle * pi * 2;
    float2 pos = float2(in.x, in.y);
    
    float4 c = 0.0;
    float amounts = 0.0;
    if (in.type == 1) {
        
        // Circle
        
        for (int i = 0; i < res * 3; ++i) {
            float fraction = float(i) / float(res * 3);
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            float ang = fraction * pi * 2;
            xu += cos(ang - angle) * in.radius * lum / (32 * 100);
            yv += sin(ang - angle) * in.radius * lum / (32 * 100);
            c += inTexA.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (in.type == 2) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            if (aspect < 1.0) {
                xu += ((float(x) / w) * cos(-angle) * in.radius * lum) / res;
                yv += ((float(x) / w) * sin(-angle) * in.radius * lum) / res;
            } else {
                xu += ((float(x) / h) * cos(-angle) * in.radius * lum) / res;
                yv += ((float(x) / h) * sin(-angle) * in.radius * lum) / res;
            }
            c += inTexA.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    } else if (in.type == 3) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            float fraction = (float(x) / float(res)) / 2.0 + 0.5;
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            if (aspect < 1.0) {
                xu += (((float(x) * (u - 0.5 - pos.x)) / w) * in.radius * lum) / res;
                yv += (((float(x) * (v - 0.5 + pos.y)) / w) * in.radius * lum) / res;
            } else {
                xu += (((float(x) * (u - 0.5 - pos.x)) / h) * in.radius * lum) / res;
                yv += (((float(x) * (v - 0.5 + pos.y)) / h) * in.radius * lum) / res;
            }
            c += inTexA.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    }
    
    c *= 2;
    c /= amounts;
    c *= in.light;
    
    return c;
}


