//
//  EffectSingleResPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2018-01-15.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float place;
    float aspect;
};

fragment float4 effectSingleResPIX(VertexOut out [[stage_in]],
                                   texture2d<float>  inTex [[ texture(0) ]],
                                   const device Uniforms& in [[ buffer(0) ]],
                                   sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    // Place
    float aspect_a = in.aspect;
    uint w = inTex.get_width();
    uint h = inTex.get_height();
    float aspect_b = float(w) / float(h);
    float bu = u;
    float bv = v;
    switch (int(in.place)) {
        case 1: // Aspect Fit
            if (aspect_b > aspect_a) {
                bv /= aspect_a;
                bv *= aspect_b;
                bv += ((aspect_a - aspect_b) / 2) / aspect_a;
            } else if (aspect_b < aspect_a) {
                bu /= aspect_b;
                bu *= aspect_a;
                bu += ((aspect_b - aspect_a) / 2) / aspect_b;
            }
            break;
        case 2: // Aspect Fill
            if (aspect_b > aspect_a) {
                bu *= aspect_a;
                bu /= aspect_b;
                bu += ((1.0 / aspect_a - 1.0 / aspect_b) / 2) * aspect_a;
            } else if (aspect_b < aspect_a) {
                bv *= aspect_b;
                bv /= aspect_a;
                bv += ((1.0 / aspect_b - 1.0 / aspect_a) / 2) * aspect_b;
            }
            break;
    }
    
    float4 c = inTex.sample(s, float2(bu, bv));
    
    return c;
}
