//
//  ContentGeneratorNoisePIX.metal
//  Pixels Shaders
//
//  Created by Hexagons on 2017-11-24.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "noise_header.metal"
#import "random_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float seed;
    float octaves;
    float x;
    float y;
    float z;
    float zoom;
    float color;
    float random;
    float premultiply;
    float aspect;
};

fragment float4 contentGeneratorNoisePIX(VertexOut out [[stage_in]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
    
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float ux = (u * in.aspect - in.x - 0.5 * in.aspect) / in.zoom;
    float vy = (v - in.y - 0.5) / in.zoom;
    

    float n;
    if (in.random > 0.5) {
        Loki loki_rnd = Loki(in.seed, u * max_res, v * max_res);
        n = loki_rnd.rand();
    } else {
        n = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 100 + in.seed * 100);
        n = n / 2 + 0.5;
    }
    
    float ng;
    float nb;
    if (in.color > 0.5) {
        if (in.random > 0.5) {
            Loki loki_rnd_g = Loki(in.seed + 100, u * max_res, v * max_res);
            ng = loki_rnd_g.rand();
            Loki loki_rnd_b = Loki(in.seed + 200, u * max_res, v * max_res);
            nb = loki_rnd_b.rand();
        } else {
            ng = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 200 + in.seed * 100);
            ng = ng / 2 + 0.5;
            nb = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 300 + in.seed * 100);
            nb = nb / 2 + 0.5;
        }
    }
    
    float r = n;
    float g = in.color > 0.5 ? ng : n;
    float b = in.color > 0.5 ? nb : n;
    
    return float4(r, g, b, 1.0);
}
