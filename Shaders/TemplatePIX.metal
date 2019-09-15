//
//  TemplatePIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-17.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 templatePIX(VertexOut out [[stage_in]],
                            sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    
    float c = 0;
    
    float dist = sqrt(pow((u - 0.5) * in.aspect - in.x, 2) + pow(v - 0.5 - in.y, 2));
    if (dist > 0.475 && dist < 0.5) {
        c = 1.0;
    }
    
    return float4(u * c, v * c, c, 1.0);
}
