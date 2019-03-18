//
//  Error.metal
//  Pixel Nodes
//
//  Created by Hexagons on 2017-11-29.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 error(VertexOut out [[stage_in]],
                      texture2d<float>  inTex [[ texture(0) ]],
                      sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = 1.0 - out.texCoord[1];
    
    bool err_u = u * 6 - floor(u * 6) > 0.5;
    bool err_v = v * 6 - floor(v * 6) > 0.5;
    bool err = abs(err_u - err_v);
    
    float r = err;
    float g = 0;
    float b = !err;
    
    return float4(r, g, b, 1.0);
}


