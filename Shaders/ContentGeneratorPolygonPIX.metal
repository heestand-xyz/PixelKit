//
//  ContentGeneratorPolygonPIX.metal
//  Pixels Shaders
//
//  Created by Hexagons on 2017-11-21.
//  Copyright © 2017 Hexagons. All rights reserved.
//
//  https://stackoverflow.com/a/2049593/4586652
//

#include <metal_stdlib>
using namespace metal;


float sign(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool pointInTriangle(float2 pt, float2 v1, float2 v2, float2 v3) {
    bool b1, b2, b3;
    b1 = sign(pt, v1, v2) < 0.0f;
    b2 = sign(pt, v2, v3) < 0.0f;
    b3 = sign(pt, v3, v1) < 0.0f;
    return (b1 == b2) && (b2 == b3);
}

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float s;
    float x;
    float y;
    float r;
    float i;
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

fragment float4 contentGeneratorPolygonPIX(VertexOut out [[stage_in]],
                                           const device Uniforms& in [[ buffer(0) ]],
                                           sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    float2 uv = float2(u, v);
    
    float2 p = float2(in.x / in.aspect, in.y);
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);

    float4 c = bc;
    
    for (int i = 0; i < int(in.i); ++i) {
        float fia = float(i) / in.i;
        float fib = float(i + 1) / in.i;
        float2 p1 = 0.5 + p;
        float p2r = (fia + in.r) * pi * 2;
        float2 p2 = p1 + float2((sin(p2r) * in.s) / in.aspect, cos(p2r) * in.s);
        float p3r = (fib + in.r) * pi * 2;
        float2 p3 = p1 + float2((sin(p3r) * in.s) / in.aspect, cos(p3r) * in.s);
        if (pointInTriangle(uv, p1, p2, p3)) {
            c = ac;
            break;
        }
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
