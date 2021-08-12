//
//  EffectSingleSlopePIX.metal
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
    float amp;
};

fragment float4 effectSingleSlopePIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    uint w = inTex.get_width();
    uint h = inTex.get_height();
    float2 uv = float2(u, v);
    float2 uvu = float2(u + (1.0 / float(w)), v);
    float2 uvv = float2(u, v + (1.0 / float(h)));
    
    if (uvu.x > 1.0) {
        return float4(0.5, 0.5, 0.5, 1.0);
    }
    if (uvv.y > 1.0) {
        return float4(0.5, 0.5, 0.5, 1.0);
    }
    
    float4 c = inTex.sample(s, uv);
    float4 cu = inTex.sample(s, uvu);
    float4 cv = inTex.sample(s, uvv);
    float c_avg = (c.r + c.g + c.b) / 3.0;
    float cu_avg = (cu.r + cu.g + cu.b) / 3.0;
    float cv_avg = (cv.r + cv.g + cv.b) / 3.0;
    
    float slope_u = 0.5 + (c_avg - cu_avg) * in.amp * 0.5;
    float slope_v = 0.5 - (c_avg - cv_avg) * in.amp * 0.5;
    
    return float4(slope_u, slope_v, 0.5, 1.0);
}
