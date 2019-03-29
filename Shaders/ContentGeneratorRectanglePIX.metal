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
    float cr;
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
    
    float x = (u - 0.5) * in.aspect;
    float y = v - 0.5;
    
    float left = in.x - in.sx / 2;
    float right = in.x + in.sx / 2;
    float bottom = -in.y - in.sy / 2;
    float top = -in.y + in.sy / 2;
    
    float width = right - left;
    float height = top - bottom;
    
    float cr = min(min(in.cr, width / 2), height / 2);
   
    float in_x = x > left && x < right;
    float in_y = y > bottom && y < top;
    
    if (cr == 0.0) {
        if (in_x && in_y) {
            c = ac;
        }
    } else {
        float in_x_inset = x > left + cr && x < right - cr;
        float in_y_inset = y > bottom + cr && y < top - cr;
        if ((in_x_inset && in_y) || (in_x && in_y_inset)) {
            c = ac;
        }
        float2 c1 = float2(left + cr, bottom + cr);
        float2 c2 = float2(left + cr, top - cr);
        float2 c3 = float2(right - cr, bottom + cr);
        float2 c4 = float2(right - cr, top - cr);
        float c1r = sqrt(pow(x - c1.x, 2) + pow(y - c1.y, 2));
        float c2r = sqrt(pow(x - c2.x, 2) + pow(y - c2.y, 2));
        float c3r = sqrt(pow(x - c3.x, 2) + pow(y - c3.y, 2));
        float c4r = sqrt(pow(x - c4.x, 2) + pow(y - c4.y, 2));
        if (c1r < cr || c2r < cr || c3r < cr || c4r < cr) {
            c = ac;
        }
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
