//
//  ContentGeneratorLinePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float lineSign(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool linePointInTriangle(float2 pt, float2 v1, float2 v2, float2 v3) {
    bool b1, b2, b3;
    b1 = lineSign(pt, v1, v2) < 0.0f;
    b2 = lineSign(pt, v2, v3) < 0.0f;
    b3 = lineSign(pt, v3, v1) < 0.0f;
    return (b1 == b2) && (b2 == b3);
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
    float lw;
    float cap;
    float ar;
    float ag;
    float ab;
    float aa;
    float br;
    float bg;
    float bb;
    float ba;
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

fragment float4 contentGeneratorLinePIX(VertexOut out [[stage_in]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.tile > 0.0) {
        u = (in.tileX / in.tileResX) + u * in.tileFraction;
        v = (in.tileY / in.tileResY) + v * in.tileFraction;
    }
    v = 1 - v; // Content Flip Fix
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float x = (u - 0.5) * in.aspect;
    float y = v - 0.5;
    float2 p = float2(x, y);
    
    float2 leading = float2(in.xf, in.yf);
    float2 trailing = float2(in.xt, in.yt);
    float angle = atan2(trailing.y - leading.y, trailing.x - leading.x);
    float scale = in.lw / 2.0;
    int cap = int(in.cap);
    
    float2 leadingUp = float2(leading.x + cos(angle + pi / 2) * scale, leading.y + sin(angle + pi / 2) * scale);
    float2 leadingDown = float2(leading.x + cos(angle - pi / 2) * scale, leading.y + sin(angle - pi / 2) * scale);
    float2 trailingUp = float2(trailing.x + cos(angle + pi / 2) * scale, trailing.y + sin(angle + pi / 2) * scale);
    float2 trailingDown = float2(trailing.x + cos(angle - pi / 2) * scale, trailing.y + sin(angle - pi / 2) * scale);
    
    bool firstTriangle = linePointInTriangle(p, leadingUp, leadingDown, trailingUp);
    bool secondTriangle = linePointInTriangle(p, leadingDown, trailingUp, trailingDown);
    
    if (firstTriangle || secondTriangle) {
        c = ac;
    }
    
    if (cap == 1) {
        float leadingCircle = sqrt(pow(leading.x - p.x, 2) + pow(leading.y - p.y, 2));
        float trailingCircle = sqrt(pow(trailing.x - p.x, 2) + pow(trailing.y - p.y, 2));
        if (leadingCircle < scale || trailingCircle < scale) {
            c = ac;
        }
    } else if (cap == 2) {
        float2 leadingOut = float2(leading.x + cos(angle + pi) * scale, leading.y + sin(angle + pi) * scale);
        float2 trailingOut = float2(trailing.x + cos(angle) * scale, trailing.y + sin(angle) * scale);
        bool leadingTriangle = linePointInTriangle(p, leadingUp, leadingDown, leadingOut);
        bool trailingTriangle = linePointInTriangle(p, trailingUp, trailingDown, trailingOut);
        if (leadingTriangle || trailingTriangle) {
            c = ac;
        }
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
