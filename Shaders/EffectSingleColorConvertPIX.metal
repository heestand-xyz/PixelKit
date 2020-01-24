//
//  EffectSingleColorConvertPIX.metal
//  PixelKitShaders
//
//  Created by Hexagons on 2017-11-18.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "Shaders/Source/Effects/hsv_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float way;
    float index;
};

fragment float4 effectSingleColorConvertPIX(VertexOut out [[stage_in]],
                                            texture2d<float>  inTex [[ texture(0) ]],
                                            const device Uniforms& in [[ buffer(0) ]],
                                            sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    uint way = uint(in.way);
    uint index = uint(in.index);
    
    float3 cc = 0;
    if (way == 0) { // rgbToHsv
        cc = rgb2hsv(c.r, c.g, c.b);
    } else if (way == 1) { // hsvToRgb
        cc = hsv2rgb(c.r, c.g, c.b);
    }
    
    switch (index) {
        case 0: // all
            return float4(cc[0], cc[1], cc[2], c.a);
        case 1: // first
            return float4(cc[0], cc[0], cc[0], c.a);
        case 2: // second
            return float4(cc[1], cc[1], cc[1], c.a);
        case 3: // third
            return float4(cc[2], cc[2], cc[2], c.a);
        default:
            return 0.0;
    }
    
}
