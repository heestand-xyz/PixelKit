//
//  EffectMultiStackPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2020-06-01.
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
    float aspect0;
    float aspect1;
    float aspect2;
    float aspect3;
    float aspect4;
    float aspect5;
    float aspect6;
    float aspect7;
    float aspect8;
    float aspect9;
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
    float4 bg = float4(in.bg_r * in.bg_a, in.bg_g * in.bg_a, in.bg_b * in.bg_a, in.bg_a);
    
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
    float relativeFullAspect = isVertical ? fullAspect : (1.0 / fullAspect);

    float4 c = bg;
    float offset = padding;
    for (uint i = 0; i < count; i++) {
        
        
        float fullCoordinate = isVertical ? v : u;
        float coordinate = (fullCoordinate - offset) / sizeFraction;
        offset += sizeFraction + spacing;
        if (coordinate < 0.0 || coordinate > 1.0) { continue; }
                
        float aspect = relativeFullAspect;
        switch (i) {
            case 0: aspect = in.aspect0; break;
            case 1: aspect = in.aspect1; break;
            case 2: aspect = in.aspect2; break;
            case 3: aspect = in.aspect3; break;
            case 4: aspect = in.aspect4; break;
            case 5: aspect = in.aspect5; break;
            case 6: aspect = in.aspect6; break;
            case 7: aspect = in.aspect7; break;
            case 8: aspect = in.aspect8; break;
            case 9: aspect = in.aspect9; break;
        }
        float relativeAspect = isVertical ? aspect : (1.0 / aspect);
        float tangentSizeFraction = (sizeFraction * relativeAspect) / relativeFullAspect;

        float fullTangentCoordinate = isVertical ? u : v;
        float tangentCoordinate = 0.0;
        switch (isVertical ? alignment : -alignment) {
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
                        
    }
    
    return c;
}
