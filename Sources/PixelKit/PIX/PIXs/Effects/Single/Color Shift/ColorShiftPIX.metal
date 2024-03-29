//
//  EffectSingleColorShiftPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-18.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../MetalShaders/Effects/hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float hue;
    float sat;
    float r;
    float g;
    float b;
    float a;
};

fragment float4 effectSingleColorShiftPIX(VertexOut out [[stage_in]],
                                          texture2d<float>  inTex [[ texture(0) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    c *= float4(in.r, in.g, in.b, 1.0);
    
    float3 hsv = rgb2hsv(c.r, c.g, c.b);
    
    hsv[0] += in.hue;
    hsv[1] *= in.sat;
    
    float3 cc = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    return float4(cc.r * in.a, cc.g * in.a, cc.b * in.a, c.a * in.a);
}
