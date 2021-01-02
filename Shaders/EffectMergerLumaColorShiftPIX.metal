//
//  EffectMergerLumaColorShiftPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2020-06-01.
//

#include <metal_stdlib>
using namespace metal;

#import "Shaders/Source/Effects/hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float hue;
    float sat;
    float r;
    float g;
    float b;
    float a;
};

fragment float4 effectMergerLumaColorShiftPIX(VertexOut out [[stage_in]],
                                              texture2d<float>  inTexA [[ texture(0) ]],
                                              texture2d<float>  inTexB [[ texture(1) ]],
                                              const device Uniforms& in [[ buffer(0) ]],
                                              sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTexA.sample(s, uv);
    
    float4 cb = inTexB.sample(s, uv);
    float lum = (cb.r + cb.g + cb.b) / 3;
    
    c *= float4(1.0 - ((1.0 - in.r) * lum),
                1.0 - ((1.0 - in.g) * lum),
                1.0 - ((1.0 - in.b) * lum),
                1.0);
    
    float3 hsv = rgb2hsv(c.r, c.g, c.b);
    
    hsv[0] += in.hue * lum;
    hsv[1] *= 1.0 + (in.sat - 1.0) * lum;
    
    float3 cc = hsv2rgb(hsv[0], hsv[1], hsv[2]);
    
    float alpha = 1.0 - ((1.0 - in.a) * lum);
    return float4(cc.r * alpha, cc.g * alpha, cc.b * alpha, c.a * alpha);
}


