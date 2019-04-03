//
//  EffectMergerBlendPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-11-10.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 lerpColor(float4 fraction, float4 from, float4 to) {
    return from * (1.0 - fraction) + to * fraction;
}

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float mode;
    float transform;
    float tx;
    float ty;
    float rot;
    float s;
    float sx;
    float sy;
    float place;
};

fragment float4 effectMergerBlendPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTexA [[ texture(0) ]],
                                      texture2d<float>  inTexB [[ texture(1) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {

    float pi = 3.14159265359;

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint w = inTexB.get_width();
    uint h = inTexB.get_height();
    float aspect = float(w) / float(h);
    
    float4 ca = inTexA.sample(s, uv);
    
    // Place
    // CHECK swap a & b
    uint aw = inTexA.get_width();
    uint ah = inTexA.get_height();
    float aspect_a = float(aw) / float(ah);
    uint bw = inTexB.get_width();
    uint bh = inTexB.get_height();
    float aspect_b = float(bw) / float(bh);
    float bu = u;
    float bv = v;
    switch (int(in.place)) {
        case 1: // Aspect Fit
            if (aspect_b > aspect_a) {
                bv /= aspect_a;
                bv *= aspect_b;
                bv += ((aspect_a - aspect_b) / 2) / aspect_a;
            } else if (aspect_b < aspect_a) {
                bu /= aspect_b;
                bu *= aspect_a;
                bu += ((aspect_b - aspect_a) / 2) / aspect_b;
            }
            break;
        case 2: // Aspect Fill
            if (aspect_b > aspect_a) {
                bu *= aspect_a;
                bu /= aspect_b;
                bu += ((1.0 / aspect_a - 1.0 / aspect_b) / 2) * aspect_a;
            } else if (aspect_b < aspect_a) {
                bv *= aspect_b;
                bv /= aspect_a;
                bv += ((1.0 / aspect_b - 1.0 / aspect_a) / 2) * aspect_b;
            }
            break;
        case 3: // Center
            bu = 0.5 + ((u - 0.5) * aw) / bw;
            bv = 0.5 + ((v - 0.5) * ah) / bh;
            break;
    }
    
    // CHECK change to a
    float4 cb;
    if (in.transform) {
        float2 size = float2(in.sx * in.s, in.sy * in.s);
        float ang = atan2(bv - 0.5 - in.ty, (bu - 0.5) * aspect - in.tx) + (-in.rot / 360) * pi * 2;
        float amp = sqrt(pow((bu - 0.5) * aspect - in.tx, 2) + pow(bv - 0.5 - in.ty, 2));
        float2 buv = float2((cos(ang) / aspect) * amp, sin(ang) * amp) / size + 0.5;
        cb = inTexB.sample(s, buv);
    } else {
        cb = inTexB.sample(s, float2(bu, bv));
    }
    
    float4 c;
    float3 rgb_a = float3(ca);
    float3 rgb_b = float3(cb);
    float alpha = max(ca.a, cb.a);
    switch (int(in.mode)) {
        case 0: // Over
            c = float4(rgb_a * (1.0 - cb.a) + rgb_b * cb.a, alpha);
            break;
        case 1: // Under
            c = float4(rgb_a * ca.a + rgb_b * (1.0 - ca.a), alpha);
            break;
        case 2: // Add
            c = ca + cb;
            break;
        case 3: // Mult
            c = ca * cb;
            break;
        case 4: // Diff
            c = float4(abs(rgb_a - rgb_b), alpha);
            break;
        case 5: // Sub
            c = ca - cb;
            break;
        case 6: // Sub Color
            c = float4(rgb_a - rgb_b, alpha);
            break;
        case 7: // Max
            c = max(ca, cb);
            break;
        case 8: // Min
            c = min(ca, cb);
            break;
        case 9: // Gamma
            c = pow(ca, 1 / cb);
            break;
        case 10: // Power
            c = pow(ca, cb);
            break;
        case 11: // Divide
            c = ca / cb;
            break;
        case 12: // Average
            c = ca / 2 + cb / 2;
            break;
        case 13: // Cosine
            c = lerpColor(cb, ca, cos(ca * pi + pi) / 2 + 0.5);
            break;
    }
    
    return c;
}
