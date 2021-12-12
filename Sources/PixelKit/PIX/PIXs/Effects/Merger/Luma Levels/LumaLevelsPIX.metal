//
//  EffectMergerLumaLevelsPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../Shaders/Source/Content/random_header.metal"

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
    float offset;
    float lumaGamma;
};

fragment float4 effectMergerLumaLevelsPIX(VertexOut out [[stage_in]],
                                          texture2d<float>  inTexA [[ texture(0) ]],
                                          texture2d<float>  inTexB [[ texture(1) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTexA.sample(s, uv);
    
    float4 cb = inTexB.sample(s, uv);
    float lum = (cb.r + cb.g + cb.b) / 3;
    lum = pow(lum, 1 / max(0.001, in.lumaGamma));
    
    float opacity = (1.0 - (1.0 - in.opacity) * lum);
    float a = c.a * opacity;
    
    c *= 1 / (1.0 - in.darkness * lum);
    c -= 1.0 / (1.0 - in.darkness * lum) - 1;
    
    c *= 1.0 - (1.0 - in.brightness) * lum;
    
    c -= 0.5;
    c *= 1.0 + in.contrast * lum;
    c += 0.5;
    
    c = pow(c, 1 / max(0.001, 1.0 - (1.0 - in.gamma) * lum));
    
    if (in.invert) {
        float4 ci = 1.0 - c;
        c = c * (1.0 - lum) + ci * lum;
    }
    
    if (in.smooth) {
        float4 cl = min(max(c, 0.0), 1.0);
        float4 cs = cos(cl * pi + pi) / 2 + 0.5;
        c = c * (1.0 - lum) + cs * lum;
    }
    
    c += in.offset;
    
    c *= opacity;
    
    return float4(c.r, c.g, c.b, a);
}


