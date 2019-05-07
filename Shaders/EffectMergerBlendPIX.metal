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
    
    float rot = in.rot * pi * 2;
    
    float4 ca = inTexA.sample(s, uv);
    
//    // Kernels
//    switch (int(in.mode)) {
//        case 2: // Add
//            return ca;
//        case 3: // Mult
//            return ca;
//        case 5: // Sub
//            return ca;
//    }
    
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
        float x = (bu - 0.5) * aspect - in.tx;
        float y = bv - 0.5 + in.ty;
        float ang = atan2(y, x) - rot;
        float amp = sqrt(pow(x, 2) + pow(y, 2));
        float2 buv = float2((cos(ang) / aspect) * amp, sin(ang) * amp) / size + 0.5;
        cb = inTexB.sample(s, buv);
    } else {
        cb = inTexB.sample(s, float2(bu, bv));
    }
    
    float4 c;
    float3 rgb_a = float3(ca);
    float3 rgb_b = float3(cb);
    float aa = max(ca.a, cb.a);
    float ia = min(ca.a, cb.a);
    float oa = ca.a - cb.a;
    float xa = abs(ca.a - cb.a);
    switch (int(in.mode)) {
        case 0: // Over
            c = float4(rgb_a * (1.0 - cb.a) + rgb_b * cb.a, aa);
            break;
        case 1: // Under
            c = float4(rgb_a * ca.a + rgb_b * (1.0 - ca.a), aa);
            break;
        case 2: // Add Color
            c = float4(rgb_a + rgb_b, aa);
            break;
        case 3: // Add
            c = ca + cb;
            break;
        case 4: // Mult
            c = ca * cb;
            break;
        case 5: // Diff
            c = float4(abs(rgb_a - rgb_b), aa);
            break;
        case 6: // Sub Color
            c = float4(rgb_a - rgb_b, aa);
            break;
        case 7: // Sub
            c = ca - cb;
            break;
        case 8: // Max
            c = max(ca, cb);
            break;
        case 9: // Min
            c = min(ca, cb);
            break;
        case 10: // Gamma
            c = pow(ca, 1 / cb);
            break;
        case 11: // Power
            c = pow(ca, cb);
            break;
        case 12: // Divide
            c = ca / cb;
            break;
        case 13: // Average
            c = ca / 2 + cb / 2;
            break;
        case 14: // Cosine
            c = lerpColor(min(cb.r, 1.0), ca, cos(ca * pi + pi) / 2 + 0.5);
            for (int i = 1; i < int(ceil(cb.r)); i++) {
                c = lerpColor(min(max(cb.r - float(i), 0.0), 1.0), c, cos(c * pi + pi) / 2 + 0.5);
            }
            break;
        case 15: // Inside Source
            c = float4(rgb_a * ia, ia);
            break;
//        case 15: // Inside Destination
//            c = float4(rgb_b * ia, ia);
//            break;
        case 16: // Outside Source
            c = float4(rgb_a * oa, oa);
            break;
//        case 17: // Outside Destination
//            c = float4(rgb_b * oa, oa);
//            break;
        case 17: // XOR
            c = float4(rgb_a * (ca.a * xa) + rgb_b * (cb.a * xa), xa);
            break;
    }
    
    return c;
}
