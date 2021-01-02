//
//  EffectSingleThresholdPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-30.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float threshold;
};

fragment float4 effectSingleThresholdPIX(VertexOut out [[stage_in]],
                                         texture2d<float>  inTex [[ texture(0) ]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    float bw = (c.r + c.g + c.b) / 3;
    
    float t = 0.0;
    if (bw > in.threshold) {
        t = 1.0;
    }
    
    return float4(t, t, t, 1.0);
}
