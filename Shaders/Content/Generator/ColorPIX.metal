//
//  ContentGeneratorColorPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-16.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float r;
    float g;
    float b;
    float a;
    float premultiply;
    float aspect;
    float tile;
    float tileX;
    float tileY;
    float tileResX;
    float tileResY;
    float tileFraction;
};

fragment float4 contentGeneratorColorPIX(VertexOut out [[stage_in]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    
    float4 c = float4(in.r, in.g, in.b, in.a);

    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}

