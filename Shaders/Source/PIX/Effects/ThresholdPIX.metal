//
//  ThresholdPIX.metal
//  HxPxE
//
//  Created by Hexagons on 2017-11-30.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float threshold;
    float smoothness;
};

fragment float4 thresholdPIX(VertexOut out [[stage_in]],
                             texture2d<float>  inTex [[ texture(0) ]],
                             const device Uniforms& in [[ buffer(0) ]],
                             sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    float bw = (c.r + c.g + c.b) / 3;
    
    float smoothness = in.smoothness;
    if (smoothness < 1.0 / 256) {
        smoothness = 1.0 / 256;
    }
    
    float t = (bw - in.threshold) / smoothness + in.threshold;
    if (t < 0) {
        t = 0;
    } else if (t > 1) {
        t = 1;
    }
    
    return float4(t, t, t, 1.0);
}
