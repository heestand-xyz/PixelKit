//
//  EffectMergerLumaBlurPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "Shaders/Source/Content/random_header.metal"

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
};

fragment float4 effectMergerLumaBlurPIX(VertexOut out [[stage_in]],
                                        texture2d<float>  inTexA [[ texture(0) ]],
                                        texture2d<float>  inTexB [[ texture(1) ]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 ca = inTexA.sample(s, uv);
    
    float4 cb = inTexB.sample(s, uv);
    
    float lum = (cb.r + cb.g + cb.b) / 3;
    
    uint w = inTexA.get_width();
    uint h = inTexA.get_height();
    float aspect = w / h;
    
    int res = int(in.res);
    
    float angle = in.angle * pi * 2;
    float2 pos = float2(in.x, in.y);
    
    float amounts = 1.0;
    
    if (in.type < 0.5) {
        
        // Regular
        
        for (int x = -res; x <= res; ++x) {
            for (int y = -res; y <= res; ++y) {
                if (x != 0 && y != 0) {
                    float dist = sqrt(pow(float(x), 2) + pow(float(y), 2));
                    if (dist <= res) {
                        float amount = pow(1.0 - dist / (res + 1), 0.5);
                        float xu = u;
                        float yv = v;
                        if (aspect < 1.0) {
                            xu += ((float(x) / w) * in.radius * lum) / res;
                            yv += ((float(y) / w) * in.radius * lum) / res;
                        } else {
                            xu += ((float(x) / h) * in.radius * lum) / res;
                            yv += ((float(y) / h) * in.radius * lum) / res;
                        }
                        ca += inTexA.sample(s, float2(xu, yv)) * amount;
                        amounts += amount;
                    }
                }
            }
        }
        
    } else if (in.type > 0.5 && in.type < 1.5) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u;
                float yv = v;
                if (aspect < 1.0) {
                    xu += ((float(x) / w) * cos(-angle) * in.radius * lum) / res;
                    yv += ((float(x) / w) * sin(-angle) * in.radius * lum) / res;
                } else {
                    xu += ((float(x) / h) * cos(-angle) * in.radius * lum) / res;
                    yv += ((float(x) / h) * sin(-angle) * in.radius * lum) / res;
                }
                ca += inTexA.sample(s, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (in.type > 1.5 && in.type < 2.5) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u;
                float yv = v;
                if (aspect < 1.0) {
                    xu += (((float(x) * (u - 0.5 - pos.x)) / w) * in.radius * lum) / res;
                    yv += (((float(x) * (v - 0.5 + pos.y)) / w) * in.radius * lum) / res;
                } else {
                    xu += (((float(x) * (u - 0.5 - pos.x)) / h) * in.radius * lum) / res;
                    yv += (((float(x) * (v - 0.5 + pos.y)) / h) * in.radius * lum) / res;
                }
                ca += inTexA.sample(s, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (in.type > 2.5 && in.type < 3.5) {
        
        // Radial
        
//        for (int x = -res; x <= res; ++x) {
//            if (x != 0) {
//                float amount = pow(1.0 - x / (res + 1), 0.5);
//                float xu = u;
//                float yv = v;
//                if (aspect < 1.0) {
//                    xu += ((float(x) / w) * cos(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius * lum) / res;
//                    yv += ((float(x) / w) * sin(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius * lum) / res;
//                } else {
//                    xu += ((float(x) / h) * cos(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius * lum) / res;
//                    yv += ((float(x) / h) * sin(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius * lum) / res;
//                }
//                ca += inTexA.sample(s, float2(xu, yv)) * amount;
//                amounts += amount;
//            }
//        }
        
    } else if (in.type > 3.5 && in.type < 4.5) {
        
        // Random
        
        Loki loki_rnd_u = Loki(0, u * max_res, v * max_res);
        float ru = loki_rnd_u.rand();
        Loki loki_rnd_v = Loki(1, u * max_res, v * max_res);
        float rv = loki_rnd_v.rand();
        float2 ruv = uv + (float2(ru, rv) - 0.5) * in.radius * lum * 0.001;
        ca = inTexA.sample(s, ruv);
        
    }
    
    ca /= amounts;
    
    return ca;
}


