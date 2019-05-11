//
//  EffectSingleTwirlPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2018-08-11.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float strength;
};

fragment float4 effectSingleTwirlPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float ang = atan2(v - 0.5, u - 0.5);
    float rad = sqrt(pow(u - 0.5, 2) + pow(v - 0.5, 2));
    
    ang += pi * rad * in.strength;
    
    u = 0.5 + cos(ang) * rad;
    v = 0.5 + sin(ang) * rad;
    
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}


