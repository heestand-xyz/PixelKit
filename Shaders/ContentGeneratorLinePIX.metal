//
//  ContentGeneratorLinePIX.metal
//  Pixels Shaders
//
//  Created by Hexagons on 2017-11-17.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float xf;
    float yf;
    float xt;
    float yt;
    float s;
    float ar;
    float ag;
    float ab;
    float aa;
    float br;
    float bg;
    float bb;
    float ba;
    float premultiply;
    float aspect;
};

fragment float4 contentGeneratorLinePIX(VertexOut out [[stage_in]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float e = in.e;
    if (e < 0) {
        e = 0;
    }
    
    float xf = (u - 0.5) * in.aspect - in.xf;
    float yf = v - 0.5 - in.yf;
    float xt = (u - 0.5) * in.aspect - in.xt;
    float yt = v - 0.5 - in.yt;
    
    
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
