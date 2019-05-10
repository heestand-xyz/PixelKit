//
//  EffectSingleLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-07.
//  Copyright © 2017 Hexagons. All rights reserved.
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
    float opacity;
};

fragment float4 effectSingleLevelsPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    
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
    
    c *= in.opacity;
    
    return float4(c.r, c.g, c.b, a);
}


