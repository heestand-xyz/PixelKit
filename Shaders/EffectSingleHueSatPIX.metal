//
//  EffectSingleHueSatPIX.metal
//  PixelKitShaders
//
//  Created by Hexagons on 2017-11-18.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float hue;
    float sat;
};

fragment float4 effectSingleHueSatPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTex [[ texture(0) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    float3 hsv = rgb2hsv(c.r, c.g, c.b);
    
    hsv[0] += in.hue;
    hsv[1] *= in.sat;
    
    float3 cc = hsv2rgb(hsv[0], hsv[1], hsv[2]);
   
    return float4(cc.r, cc.g, cc.b, c.a);
}
