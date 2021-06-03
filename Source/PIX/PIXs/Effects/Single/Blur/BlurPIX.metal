//
//  EffectSingleBlurPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../Shaders/Shaders/Source/Content/random_header.metal"

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
    float resx;
    float resy;
    float aspect;
};

fragment float4 effectSingleBlurPIX(VertexOut out [[stage_in]],
                                    texture2d<float>  inTex [[ texture(0) ]],
                                    const device Uniforms& in [[ buffer(0) ]],
                                    sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    uint iw = inTex.get_width();
    uint ih = inTex.get_height();
    float aspect = float(iw) / float(ih);
    
    int res = int(in.res);
    
    float angle = in.angle * pi * 2;
    float2 pos = float2(in.x, in.y);
    
    float amounts = 1.0;

    if (in.type == 1) {
        
        // Box
        
        for (int x = -res; x <= res; ++x) {
            for (int y = -res; y <= res; ++y) {
                if (x != 0 && y != 0) {
                    float dist = sqrt(pow(float(x), 2) + pow(float(y), 2));
                    if (dist <= res) {
                        float amount = pow(1.0 - dist / (res + 1), 0.5);
                        float xu = u;
                        float yv = v;
                        if (aspect < 1.0) {
                            xu += ((float(x) / iw) * in.radius) / res;
                            yv += (((float(y) / iw) * in.radius) / res) * in.aspect;
                        } else {
                            xu += ((float(x) / ih) * in.radius) / res;
                            yv += (((float(y) / ih) * in.radius) / res) * in.aspect;
                        }
                        c += inTex.sample(s, float2(xu, yv)) * amount;
                        amounts += amount;
                    }
                }
            }
        }
        
    } else if (in.type == 2) {
        
        // Angle
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u;
                float yv = v;
                if (aspect < 1.0) {
                    xu += ((float(x) / iw) * cos(-angle) * in.radius) / res;
                    yv += (((float(x) / iw) * sin(-angle) * in.radius) / res) * in.aspect;
                } else {
                    xu += ((float(x) / ih) * cos(-angle) * in.radius) / res;
                    yv += (((float(x) / ih) * sin(-angle) * in.radius) / res) * in.aspect;
                }
                c += inTex.sample(s, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    } else if (in.type == 3) {
        
        // Zoom
        
        for (int x = -res; x <= res; ++x) {
            if (x != 0) {
                float amount = pow(1.0 - x / (res + 1), 0.5);
                float xu = u;
                float yv = v;
                if (aspect < 1.0) {
                    xu += (((float(x) * (u - 0.5 - pos.x)) / iw) * in.radius) / res;
                    yv += ((((float(x) * (v - 0.5 + pos.y)) / iw) * in.radius) / res);// * in.aspect;
                } else {
                    xu += (((float(x) * (u - 0.5 - pos.x)) / ih) * in.radius) / res;
                    yv += ((((float(x) * (v - 0.5 + pos.y)) / ih) * in.radius) / res);// * in.aspect;
                }
                c += inTex.sample(s, float2(xu, yv)) * amount;
                amounts += amount;
            }
        }
        
    }
//    else if (in.type == 4) {
//
//        // Radial
//
//        for (int x = -res; x <= res; ++x) {
//            if (x != 0) {
//                float amount = pow(1.0 - x / (res + 1), 0.5);
//                float xu = u;
//                float yv = v;
//                if (aspect < 1.0) {
//                    xu += ((float(x) / iw) * cos(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius) / res;
//                    yv += ((float(x) / iw) * sin(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius) / res;
//                } else {
//                    xu += ((float(x) / ih) * cos(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius) / res;
//                    yv += ((float(x) / ih) * sin(atan2(v - 0.5 + pos.y, u - 0.5 - pos.x) + pi / 2) * in.radius) / res;
//                }
//                c += inTex.sample(s, float2(xu, yv)) * amount;
//                amounts += amount;
//            }
//        }
//
//    }
    else if (in.type == 4) {
        
        // Random
        Loki loki_rnd_u = Loki(0, u * max_res, v * max_res);
        float ru = loki_rnd_u.rand();
        Loki loki_rnd_v = Loki(1, u * max_res, v * max_res);
        float rv = loki_rnd_v.rand();
        float2 ruv = uv + (float2(ru, rv) - 0.5) * in.radius * 0.001 * float2(1.0, in.aspect);
        c = inTex.sample(s, ruv);
        
    }
    
    c /= amounts;
    
    return c;
}


