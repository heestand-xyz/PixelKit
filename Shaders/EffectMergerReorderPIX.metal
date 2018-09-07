//
//  EffectMergerReorderPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2017-12-03.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float red_input;
    float red_channel;
    float green_input;
    float green_channel;
    float blue_input;
    float blue_channel;
    float alpha_input;
    float alpha_channel;
    float premultiply;
    float place;
};

fragment float4 effectMergerReorderPIX(VertexOut out [[stage_in]],
                                        texture2d<float>  inTexA [[ texture(0) ]],
                                        texture2d<float>  inTexB [[ texture(1) ]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 ca = inTexA.sample(s, uv);
    
    // Place
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
    }
    float4 cb = inTexB.sample(s, float2(bu, bv));
    
    int chan_r = in.red_channel;
    int chan_g = in.green_channel;
    int chan_b = in.blue_channel;
    int chan_a = in.alpha_channel;

    float lum_a = (ca.r + ca.g + ca.b) / 3;
    float lum_b = (cb.r + cb.g + cb.b) / 3;
    
    float4 c = float4(
        chan_r < 4 ? (in.red_input == 0 ? ca[chan_r] : cb[chan_r]) : chan_r == 4 ? 0.0 : chan_r == 5 ? 1.0 : (in.red_input == 0 ? lum_a : lum_b),
        chan_g < 4 ? (in.green_input == 0 ? ca[chan_g] : cb[chan_g]) : chan_g == 4 ? 0.0 : chan_g == 5 ? 1.0 : (in.green_input == 0 ? lum_a : lum_b),
        chan_b < 4 ? (in.blue_input == 0 ? ca[chan_b] : cb[chan_b]) : chan_b == 4 ? 0.0 : chan_b == 5 ? 1.0 : (in.blue_input == 0 ? lum_a : lum_b),
        chan_a < 4 ? (in.alpha_input == 0 ? ca[chan_a] : cb[chan_a]) : chan_a == 4 ? 0.0 : chan_a == 5 ? 1.0 : (in.alpha_input == 0 ? lum_a : lum_b)
    );
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
