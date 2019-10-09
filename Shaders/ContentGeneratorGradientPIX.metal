//
//  ContentGeneratorGradientPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-16.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Shaders/Source/Content/gradient_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float type;
    float scale;
    float offset;
    float px;
    float py;
    float extend;
    float premultiply;
    float aspect;
};

fragment float4 contentGeneratorGradientPIX(VertexOut out [[stage_in]],
                                            const device Uniforms& in [[ buffer(0) ]],
                                            const device array<ColorStopArray, ARRMAX>& inArr [[ buffer(1) ]],
                                            const device array<bool, ARRMAX>& inArrActive [[ buffer(2) ]],
                                            sampler s [[ sampler(0) ]]) {

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix

    u -= in.px / in.aspect;
    v -= in.py;

    float pi = 3.14159265359;

//    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
//    float4 bc = float4(in.br, in.bg, in.bb, in.ba);

    float fraction = 0;
    if (in.type == 0) {
        // Horizontal
        fraction = (u - in.offset) / in.scale;
    } else if (in.type == 1) {
        // Vertical
        fraction = (v - in.offset) / in.scale;
    } else if (in.type == 2) {
        // Radial
        fraction = (sqrt(pow((u - 0.5) * in.aspect, 2) + pow(v - 0.5, 2)) * 2 - in.offset) / in.scale;
    } else if (in.type == 3) {
        // Angle
        fraction = (atan2(v - 0.5, (-u + 0.5) * in.aspect) / (pi * 2) + 0.5 - in.offset) / in.scale;
    }

    FractionAndZero fz = fractionAndZero(fraction, int(in.extend));
    fraction = fz.fraction;

    float4 c = 0;
    if (!fz.zero) {
        c = gradient(fraction, inArr, inArrActive);
    }
//    else if (!zero) {
//        c = mix(ac, bc, fraction);
//    }

    if (!fz.zero && in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }

    return c;
}
