//
//  EffectSingleRainbowBlurPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../Shaders/Source/Effects/hsv_header.metal"

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
    float resx;
    float resy;
    float aspect;
};

fragment float4 effectSingleRainbowBlurPIX(VertexOut out [[stage_in]],
                                           texture2d<float>  inTex [[ texture(0) ]],
                                           const device Uniforms& in [[ buffer(0) ]],
                                           sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint iw = inTex.get_width();
    uint ih = inTex.get_height();
    float aspect = iw / ih;
    
    int res = int(in.res);
    
    float angle = in.angle * pi * 2;
    float2 pos = float2(in.x, in.y);
    
    float4 c = 0.0;
    float amounts = 1.0;
    if (in.type == 1) {
        
        // Circle
        
        for (int i = 0; i < res * 3; ++i) {
            float fraction = float(i) / float(res * 3);
            float3 rgb = hsv2rgb(fraction, 1.0, 1.0);
            float4 rgba = float4(rgb.r, rgb.g, rgb.b, 1.0);
            float xu = u;
            float yv = v;
            float ang = fraction * pi * 2;
            xu += cos(ang - angle) * in.radius / (32 * 100);
            yv += (sin(ang - angle) * in.radius / (32 * 100)) * in.aspect;
            c += inTex.sample(s, float2(xu, yv)) * rgba;
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
                xu += ((float(x) / iw) * cos(-angle) * in.radius) / res;
                yv += (((float(x) / iw) * sin(-angle) * in.radius) / res) * in.aspect;
            } else {
                xu += ((float(x) / ih) * cos(-angle) * in.radius) / res;
                yv += (((float(x) / ih) * sin(-angle) * in.radius) / res) * in.aspect;
            }
            c += inTex.sample(s, float2(xu, yv)) * rgba;
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
                xu += (((float(x) * (u - 0.5 - pos.x)) / iw) * in.radius) / res;
                yv += ((((float(x) * (v - 0.5 + pos.y)) / iw) * in.radius) / res);// * in.aspect;
            } else {
                xu += (((float(x) * (u - 0.5 - pos.x)) / ih) * in.radius) / res;
                yv += ((((float(x) * (v - 0.5 + pos.y)) / ih) * in.radius) / res);// * in.aspect;
            }
            c += inTex.sample(s, float2(xu, yv)) * rgba;
            amounts += 1.0;
        }
        
    }
    
    c *= 2;
    c /= amounts;
    c *= in.light;
    
    return c;
}


