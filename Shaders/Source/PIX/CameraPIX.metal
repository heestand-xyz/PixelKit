//
//  CameraPIX.metal
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2017-12-06.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float orientation;
    float mirror;
};

fragment float4 cameraPIX(VertexOut out [[stage_in]],
                          texture2d<float>  inTex [[ texture(0) ]],
                          const device Uniforms& in [[ buffer(0) ]],
                          sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    if (in.mirror) {
        if (int(in.orientation) == 1 || int(in.orientation) == 2) {
            uv[0] = 1.0 - uv[0];
        } else {
            uv[1] = 1.0 - uv[1];
        }
    }
    
    switch (int(in.orientation)) {
        case 1: // portrait
            uv = float2(uv[1], 1.0 - uv[0]);
            break;
        case 2: // portraitUpsideDown
            uv = float2(1.0 - uv[1], uv[0]);
            break;
        case 3: // landscapeRight
            uv = float2(1.0 - uv[0], 1.0 - uv[1]);
            break;
        case 4: // landscapeLeft
            break;
    }
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}

