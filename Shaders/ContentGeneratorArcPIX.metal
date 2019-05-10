//
//  ContentGeneratorArcPIX.metal
//  PixelKit Shaders
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
    float s;
    float af;
    float at;
    float ao;
    float x;
    float y;
    float e;
    float ar;
    float ag;
    float ab;
    float aa;
    float er;
    float eg;
    float eb;
    float ea;
    float br;
    float bg;
    float bb;
    float ba;
    float premultiply;
    float aspect;
};

fragment float4 contentGeneratorArcPIX(VertexOut out [[stage_in]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 ec = float4(in.er, in.eg, in.eb, in.ea);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float e = in.e;
    if (e < 0) {
        e = 0;
    }
    
    float x = (u - 0.5) * in.aspect - in.x;
    float y = v - 0.5 - in.y;
    
    float a = atan2(y, x);
    float af = in.af * pi * 2;
    float at = in.at * pi * 2;
    float ao = in.ao * pi * 2;
    float afo = af + ao;
    if (afo < -pi) {
        afo = afo + floor((-afo + pi) / (pi * 2)) * (pi * 2);
    } else if (afo > pi) {
        afo = afo - floor((afo + pi) / (pi * 2)) * (pi * 2);
    }
    float ato = at + ao;
    if (ato < -pi) {
        ato = ato + floor((-ato + pi) / (pi * 2)) * (pi * 2);
    } else if (ato > pi) {
        ato = ato - floor((ato + pi) / (pi * 2)) * (pi * 2);
    }
    
    if (afo < ato ?
        a >= afo && a <= ato :
        !(a <= afo && a >= ato)) {
        float dist = sqrt(pow(x, 2) + pow(y, 2));
        if (dist < in.s - e / 2) {
            c = ac;
        } else if (dist < in.s + e / 2) {
            c = ec;
        }
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
