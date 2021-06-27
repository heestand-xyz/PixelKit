//
//  EffectSingleTransformPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float tx;
    float ty;
    float rot;
    float s;
    float sx;
    float sy;
};

fragment float4 effectSingleTransformPIX(VertexOut out [[stage_in]],
                                          texture2d<float>  inTex [[ texture(0) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint w = inTex.get_width();
    uint h = inTex.get_height();
    float aspect = float(w) / float(h);

    float2 size = float2(in.sx * in.s, in.sy * in.s);

    float ang = atan2(v - 0.5 + in.ty, (u - 0.5) * aspect - in.tx) + (-in.rot * pi * 2);
    float amp = sqrt(pow((u - 0.5) * aspect - in.tx, 2) + pow(v - 0.5 + in.ty, 2));
    float2 uv = float2((cos(ang) / aspect) * amp, sin(ang) * amp) / size + 0.5;
    float4 c = inTex.sample(s, uv);
    
    return c;
}


