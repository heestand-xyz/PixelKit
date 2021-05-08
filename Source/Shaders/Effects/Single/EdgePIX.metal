//
//  EffectSingleEdgePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float amp;
    float dist;
    float colored;
    float transparent;
    float includeAlpha;
};

float edgeMono(texture2d<float> inTex, sampler s, float4 c, float u, float v, uint w, uint h, float dist, float amp) {
    float4 cup = inTex.sample(s, float2(u + dist / float(w), v));
    float4 cvp = inTex.sample(s, float2(u, v + dist / float(h)));
    float4 cun = inTex.sample(s, float2(u - dist / float(w), v));
    float4 cvn = inTex.sample(s, float2(u, v - dist / float(h)));
    float cq = (c.r + c.g + c.b) / 3;
    float cupq = (cup.r + cup.g + cup.b) / 3;
    float cvpq = (cvp.r + cvp.g + cvp.b) / 3;
    float cunq = (cun.r + cun.g + cun.b) / 3;
    float cvnq = (cvn.r + cvn.g + cvn.b) / 3;
    float e = ((abs(cq - cupq) + abs(cq - cvpq) + abs(cq - cunq) + abs(cq - cvnq)) / 4) * amp;
    return e;
}

float edgeColor(texture2d<float> inTex, sampler s, float c, float u, float v, uint w, uint h, float dist, float amp, int index) {
    float cup = inTex.sample(s, float2(u + dist / float(w), v))[index];
    float cvp = inTex.sample(s, float2(u, v + dist / float(h)))[index];
    float cun = inTex.sample(s, float2(u - dist / float(w), v))[index];
    float cvn = inTex.sample(s, float2(u, v - dist / float(h)))[index];
    float e = ((abs(c - cup) + abs(c - cvp) + abs(c - cun) + abs(c - cvn)) / 4) * amp;
    return e;
}

fragment float4 effectSingleEdgePIX(VertexOut out [[stage_in]],
                                    texture2d<float>  inTex [[ texture(0) ]],
                                    const device Uniforms& in [[ buffer(0) ]],
                                    sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 c = inTex.sample(s, uv);

    uint w = inTex.get_width();
    uint h = inTex.get_height();
    
    bool isColored = in.colored > 0.0;
    bool isTransparent = in.transparent > 0.0;
    bool doseIncludeAlpha = in.includeAlpha > 0.0;

    float e = edgeMono(inTex, s, c, u, v, w, h, in.dist, in.amp);
    float ea = 0;
    if (doseIncludeAlpha) {
        ea = edgeColor(inTex, s, c[3], u, v, w, h, in.dist, in.amp, 3);
        e += ea;
    }
    
    float4 fc = 0;
    if (!isColored) {
        fc = float4(e, e, e, isTransparent ? e : 1.0);
    } else {
        float er = edgeColor(inTex, s, c[0], u, v, w, h, in.dist, in.amp, 0);
        float eg = edgeColor(inTex, s, c[1], u, v, w, h, in.dist, in.amp, 1);
        float eb = edgeColor(inTex, s, c[2], u, v, w, h, in.dist, in.amp, 2);
        fc = float4(er, eg, eb, isTransparent ? (doseIncludeAlpha ? ea : e) : 1.0);
    }
    
    return fc;
}


