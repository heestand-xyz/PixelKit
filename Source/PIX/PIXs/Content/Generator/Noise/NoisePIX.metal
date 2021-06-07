//
//  ContentGeneratorNoisePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-24.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../Metal/Shaders/Source/Content/noise_header.metal"
#import "../../../../../Metal/Shaders/Source/Content/random_header.metal"

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
    float includeAlpha;
    float premultiply;
    float resx;
    float resy;
    float aspect;
    float tile;
    float tileX;
    float tileY;
    float tileResX;
    float tileResY;
    float tileFraction;
};

fragment float4 contentGeneratorNoisePIX(VertexOut out [[stage_in]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
    
    int max_res = 16384 - 1;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.tile > 0.0) {
        u = (in.tileX / in.tileResX) + u * in.tileFraction;
        v = (in.tileY / in.tileResY) + v * in.tileFraction;
    }
    
    float ux = (u * in.aspect - in.x - 0.5 * in.aspect) / in.zoom;
    float vy = (v - in.y - 0.5) / in.zoom;
    

    float n;
    if (in.random > 0.0) {
        Loki loki_rnd = Loki(in.seed, u * max_res, v * max_res);
        n = loki_rnd.rand();
    } else {
        n = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + in.seed * 100);
        n = n / 2 + 0.5;
    }
    
    float ng;
    float nb;
    if (in.color > 0.0) {
        if (in.random > 0.0) {
            Loki loki_rnd_g = Loki(in.seed + 100, u * max_res, v * max_res);
            ng = loki_rnd_g.rand();
            Loki loki_rnd_b = Loki(in.seed + 200, u * max_res, v * max_res);
            nb = loki_rnd_b.rand();
        } else {
            ng = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 10 + in.seed);
            ng = ng / 2 + 0.5;
            nb = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 20 + in.seed);
            nb = nb / 2 + 0.5;
        }
    }
    
    float na;
    if (in.includeAlpha > 0.0) {
        if (in.random > 0.0) {
            Loki loki_rnd_g = Loki(in.seed + 300, u * max_res, v * max_res);
            na = loki_rnd_g.rand();
        } else {
            na = octave_noise_3d(in.octaves, 0.5, 1.0, ux, vy, in.z + 30 + in.seed);
            na = na / 2 + 0.5;
        }
    }
    
    float r = n;
    float g = in.color > 0.0 ? ng : n;
    float b = in.color > 0.0 ? nb : n;
    float a = in.includeAlpha > 0.0 ? na : 1.0;

    return float4(r, g, b, a);
}
