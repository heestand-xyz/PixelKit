//
//  ContentGeneratorGradientPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-16.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "../../../../../MetalShaders/Content/gradient_header.metal"

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
    float gamma;
    float extend;
    float premultiply;
    float resx;
    float resy;
    float aspect;
    float tile;
    float tileX;
    float tileY;
    float tileResX;
    float tileResY;
    float tileFraction;
};

fragment float4 contentGeneratorGradientPIX(VertexOut out [[stage_in]],
                                            const device Uniforms& in [[ buffer(0) ]],
                                            const device array<ColorStopArray, ARRMAX>& inArr [[ buffer(1) ]],
                                            const device array<bool, ARRMAX>& inArrActive [[ buffer(2) ]],
                                            sampler s [[ sampler(0) ]]) {

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.tile > 0.0) {
        u = (in.tileX / in.tileResX) + u * in.tileFraction;
        v = (in.tileY / in.tileResY) + v * in.tileFraction;
    }
    v = 1 - v; // Content Flip Fix

    u -= in.px / in.aspect;
    v -= in.py;

    float pi = M_PI_F;

    float fraction = 0;
    if (in.type == 0) {
        // Horizontal
        fraction = (u - in.offset) / in.scale;
    } else if (in.type == 1) {
        // Vertical
        fraction = (v - in.offset) / in.scale;
    } else if (in.type == 2) {
        // Radial
        fraction = 1.0 - (sqrt(pow((u - 0.5) * in.aspect, 2) + pow(v - 0.5, 2)) * 2 + in.offset) / in.scale;
    } else if (in.type == 3) {
        // Angle
        fraction = 1.0 - (atan2((-u + 0.5) * in.aspect, -(v - 0.5)) / (pi * 2) + 0.5 + in.offset) / in.scale;
        fraction = fraction - floor(fraction);
    }
    
    FractionAndZero fz = fractionAndZero(fraction, int(in.extend));
    fraction = fz.fraction;
    
    if (in.gamma != 1.0) {
        fraction = pow(min(max(fraction, 0.0), 1.0), 1 / max(0.001, in.gamma));
    }

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
