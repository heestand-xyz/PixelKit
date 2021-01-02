//
//  EffectSingleKaleidoscopePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-28.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float divisions;
    float mirror;
    float rotation;
    float tx;
    float ty;
};

fragment float4 effectSingleKaleidoscopePIX(VertexOut out [[stage_in]],
                                            texture2d<float> inTex [[ texture(0) ]],
                                            const device Uniforms& in [[ buffer(0) ]],
                                            sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint w = inTex.get_width();
    uint h = inTex.get_height();
    float aspect = float(w) / float(h);
    
    float rot = in.rotation;
    float div = in.divisions;
    
    float ang = atan2(v - 0.5 + in.ty, (u - 0.5) * aspect - in.tx) / (pi * 2);
    float ang_big = (ang - rot) * div;
    float ang_step = ang_big - floor(ang_big);
    if (in.mirror) {
        if ((ang_big / 2) - floor(ang_big / 2) > 0.5) {
            ang_step = 1.0 - ang_step;
        }
    }
    float ang_kaleid = (ang_step / div + rot) * (pi * 2);
    float dist = sqrt(pow((u - 0.5) * aspect - in.tx, 2) + pow(v - 0.5 + in.ty, 2));
    float2 uv = float2((cos(ang_kaleid) / aspect) * dist + in.tx, sin(ang_kaleid) * dist - in.ty) + 0.5;
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}
