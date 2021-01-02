//
//  EffectSingleContrastPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-12-06.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float contrast;
};

fragment float4 effectSingleSharpenPIX(VertexOut out [[stage_in]],
                                        texture2d<float>  inTex [[ texture(0) ]],
                                        const device Uniforms& in [[ buffer(0) ]],
                                        sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float w = inTex.get_width();
    float h = inTex.get_height();
    
    float4 c = 0;
    c += inTex.sample(s, uv) * (1 + 8 * in.contrast);
    c -= inTex.sample(s, float2(u - 1.0 / w, v - 1.0 / h)) * in.contrast;
    c -= inTex.sample(s, float2(u - 1.0 / w, v)) * in.contrast;
    c -= inTex.sample(s, float2(u - 1.0 / w, v + 1.0 / h)) * in.contrast;
    c -= inTex.sample(s, float2(u, v - 1.0 / h)) * in.contrast;
    c -= inTex.sample(s, float2(u, v + 1.0 / h)) * in.contrast;
    c -= inTex.sample(s, float2(u + 1.0 / w, v - 1.0 / h)) * in.contrast;
    c -= inTex.sample(s, float2(u + 1.0 / w, v)) * in.contrast;
    c -= inTex.sample(s, float2(u + 1.0 / w, v + 1.0 / h)) * in.contrast;
    
    return c;
}
