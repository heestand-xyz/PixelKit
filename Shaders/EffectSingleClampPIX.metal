//
//  EffectSingleClampPIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2019-04-01.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float low;
    float high;
    float includeAlpha;
    float style;
};

float clampValue(float value, float low, float high, int style) {
    float rel = 0.0;
    float vala = 0.0;
    float valb = 0.0;
    if (style == 1 || style == 2 || style == 4) {
        rel = (value - low) / (high - low);
        if (rel > 0.0) {
            vala = rel - float(int(rel));
        } else {
            valb = rel + float(int(1.0 - rel));
        }
    }
    switch (style) {
        case 0: // hold
            if (value < low) {
                return low;
            } else if (value > high) {
                return high;
            }
            return value;
        case 1: // relativeLoop
            if (rel > 0.0) {
                return vala;
            } else {
                return valb;
            }
        case 2: // relativeMirror
            if (rel > 0.0) {
                return int(rel) % 2 == 0 ? 1.0 - vala : vala;
            } else {
                return int(1.0 - rel) % 2 == 0 ? 1.0 - valb : valb;
            }
        case 3: // zero
            if (value < low || value > high) {
                return 0.0;
            }
            return value;
        case 4: // relative
            if (value < low) {
                return 0.0;
            } else if (value > high) {
                return 1.0;
            }
            return rel;
        default: return 0.0;
    }
}

fragment float4 effectSingleClampPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTex [[ texture(0) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);
    
    bool doseIncludeAlpha = in.includeAlpha > 0.0;
    int style = int(in.style);
    
    float r = clampValue(c.r, in.low, in.high, style);
    float g = clampValue(c.g, in.low, in.high, style);
    float b = clampValue(c.b, in.low, in.high, style);
    float a = doseIncludeAlpha ? clampValue(c.a, in.low, in.high, style) : c.a;
    
    return float4(r, g, b, a);
}


