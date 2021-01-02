//
//  ContentResourceCameraPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-12-06.
//  Copyright © 2017 Anton Heestand. All rights reserved.
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
    float flipFlop;
};

fragment float4 contentResourceCameraPIX(VertexOut out [[stage_in]],
                                          texture2d<float>  inTex [[ texture(0) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    
    if (in.flipFlop) {
        u = 1 - u;
        v = 1 - v;
    }
    
    if (in.mirror) {
        if (int(in.orientation) == 1 || int(in.orientation) == 2) {
            // portrait
            u = 1 - u;
        } else if (int(in.orientation) == 3 || int(in.orientation) == 4) {
            // landscape
            v = 1 - v;
        }
    }
    
    float cache_u = u;
    switch (int(in.orientation)) {
        case 1: // portrait
            u = 1 - v;
            v = 1 - cache_u;
            break;
        case 2: // portraitUpsideDown
            u = v;
            v = cache_u;
            break;
        case 3: // landscapeLeft
            v = 1 - v;
            break;
        case 4: // landscapeRight
            u = 1 - u;
            break;
    }
    
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}

