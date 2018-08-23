//
//  ContentGeneratorRectanglePIX.metal
//  Pixels
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
    float sx;
    float sy;
    float x;
    float y;
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

fragment float4 contentGeneratorRectanglePIX(VertexOut out [[stage_in]],
                                              const device Uniforms& in [[ buffer(0) ]],
                                              sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float in_x = (u - 0.5) * in.aspect > in.x - in.sx / 2 && (u - 0.5) * in.aspect < in.x + in.sx / 2;
    float in_y = v - 0.5 > -in.y - in.sy / 2 && v - 0.5 < -in.y + in.sy / 2;
    if (in_x && in_y) {
        c = ac;
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
