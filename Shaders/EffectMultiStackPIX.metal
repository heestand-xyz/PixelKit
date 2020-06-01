//
//  EffectMultiStackPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2020-06-01.
//  Copyright © 2020 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float axis;
    float alignment;
    float spacing;
    float padding;
    float bg_r;
    float bg_g;
    float bg_b;
    float bg_a;
    float aspect;
};

fragment float4 effectMultiStackPIX(VertexOut out [[stage_in]],
                                    texture2d_array<float>  inTexs [[ texture(0) ]],
                                    const device Uniforms& in [[ buffer(0) ]],
                                    sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
        
    int axis = int(in.axis);
    int alignment = int(in.alignment);
    float spacing = min(max(in.spacing, 0.0), 1.0);
    float padding = min(max(in.padding, 0.0), 1.0);
    float4 bg = float4(in.bg_r, in.bg_g, in.bg_b, in.bg_a);
    
    uint count = inTexs.get_array_size();
    if (count == 0) {
        return bg;
    }
    
    float sizeFraction = 1.0;
    sizeFraction -= float(count - 1) * spacing;
    sizeFraction -= padding * 2;
    sizeFraction /= float(count);

    bool isVertical = axis == 1;

    float fullAspect = in.aspect;
        
    float4 c = bg;
    float offset = padding;
    for (uint i = 0; i < count; ++i) {
        
        float fullCoordinate = isVertical ? v : u;
        float coordinate = (fullCoordinate - offset) / sizeFraction;
        if (coordinate < 0.0 || coordinate > 1.0) { continue; }
        
        uint w = inTexs.get_width(i);
        uint h = inTexs.get_height(i);
        float aspect = float(w) / float(h);
        float antiAspect = 1.0 / aspect;
        float relativeAspect = isVertical ? aspect : antiAspect;
        float tangentSizeFraction = (sizeFraction * relativeAspect) / fullAspect;

        float fullTangentCoordinate = isVertical ? u : v;
        float tangentCoordinate = 0.0;
        switch (alignment) {
            case -1: // left / bottom
                tangentCoordinate = fullTangentCoordinate / tangentSizeFraction;
                break;
            case 0: // center
                tangentCoordinate = 0.5 + (fullTangentCoordinate - 0.5) / tangentSizeFraction;
                break;
            case 1: // right / top
                tangentCoordinate = 1.0 + (fullTangentCoordinate - 1.0) / tangentSizeFraction;
                break;
        }
        if (tangentCoordinate < 0.0 || tangentCoordinate > 1.0) { continue; }
        
        float iu = isVertical ? tangentCoordinate : coordinate;
        float iv = isVertical ? coordinate : tangentCoordinate;
        float2 iuv = float2(iu, iv);
        
        float4 ic = inTexs.sample(s, iuv, i);
        c = float4(float3(c) * (1.0 - ic.a) + float3(ic), max(c.a, ic.a));
        
        offset += sizeFraction + spacing;
        
    }
    
    return c;
}
