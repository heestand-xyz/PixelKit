//
//  EdgePIX.metal
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2017-11-21.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float amp;
    float dist;
};

fragment float4 edgePIX(VertexOut out [[stage_in]],
                        texture2d<float>  inTex [[ texture(0) ]],
                        const device Uniforms& in [[ buffer(0) ]],
                        sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);

    uint w = inTex.get_width();
    uint h = inTex.get_height();
    
    float4 cup = inTex.sample(s, float2(u + in.dist / float(w), v));
    float4 cvp = inTex.sample(s, float2(u, v + in.dist / float(h)));
    float4 cun = inTex.sample(s, float2(u - in.dist / float(w), v));
    float4 cvn = inTex.sample(s, float2(u, v - in.dist / float(h)));
    float cq = (c.r + c.g + c.b) / 3;
    float cupq = (cup.r + cup.g + cup.b) / 3;
    float cvpq = (cvp.r + cvp.g + cvp.b) / 3;
    float cunq = (cun.r + cun.g + cun.b) / 3;
    float cvnq = (cvn.r + cvn.g + cvn.b) / 3;
    
    float e = ((abs(cq - cupq) + abs(cq - cvpq) + abs(cq - cunq) + abs(cq - cvnq)) / 4) * in.amp;
    
    return float4(e, e, e, 1.0);
}


