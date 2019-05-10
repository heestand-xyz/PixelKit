//
//  ContentGeneratorLinePIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-17.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float distanceToLine(float2 p1, float2 p2, float2 point) {
    float a = p1.y-p2.y;
    float b = p2.x-p1.x;
    return abs(a*point.x+b*point.y+p1.x*p2.y-p2.x*p1.y) / sqrt(a*a+b*b);
}

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
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float x = (u - 0.5) * in.aspect;
    float y = v - 0.5;
    float2 p = float2(x, y);
    
    float2 f = float2(in.xf, in.yf);
    float2 t = float2(in.xt, in.yt);
    float2 ft = (f + t) / 2;
    float ftd = sqrt(pow(f.x - t.x, 2) + pow(f.y - t.y, 2));
    float pd = sqrt(pow(ft.x - p.x, 2) + pow(ft.y - p.y, 2));

    float d = distanceToLine(f, t, p);
    if (d < in.s && pd < ftd / 2) {
        c = ac;
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
