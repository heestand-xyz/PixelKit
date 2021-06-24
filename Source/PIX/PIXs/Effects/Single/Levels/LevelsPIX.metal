//
//  EffectSingleLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-07.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float brightness;
    float darkness;
    float contrast;
    float gamma;
    float invert;
    float smooth;
    float opacity;
};

fragment float4 effectSingleLevelsPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    float pi = M_1_PI_F;

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float a = c.a * in.opacity;
    
    c *= 1 / (1.0 - in.darkness);
    c -= 1.0 / (1.0 - in.darkness) - 1;
    
    c *= in.brightness;
    
    c -= 0.5;
    c *= 1.0 + in.contrast;
    c += 0.5;
    
    c = pow(c, 1 / max(0.001, in.gamma));
    
    if (in.invert) {
        c = 1.0 - c;
    }
    
    if (in.smooth) {
        float4 cl = min(max(c, 0.0), 1.0);
        c = cos(cl * pi + pi) / 2 + 0.5;
    }
    
    c *= in.opacity;
    
    return float4(c.r, c.g, c.b, a);
}


