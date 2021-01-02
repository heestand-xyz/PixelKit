//
//  EffectSingleQuantizePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float step;
};

fragment float4 effectSingleQuantizePIX(VertexOut out [[stage_in]],
                                        texture2d<float>  inTex [[ texture(0) ]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float step = in.step;
    float low = 1.0 / 256;
    if (step < low) {
        step = low;
    }
    float4 q = floor(c / step) * step;
    
    float4 cc = float4(q.r, q.g, q.b, c.a);
    
    return cc;
}


