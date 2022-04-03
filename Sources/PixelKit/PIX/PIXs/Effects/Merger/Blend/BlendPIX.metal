//
//  EffectMergerBlendPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../MetalShaders/Effects/place_header.metal"
#import "../../../../../MetalShaders/Effects/blend_header.metal"

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float mode;
    float transform;
    float tx;
    float ty;
    float rot;
    float s;
    float sx;
    float sy;
    float place;
};

fragment float4 effectMergerBlendPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTexA [[ texture(0) ]],
                                      texture2d<float>  inTexB [[ texture(1) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {

    float pi = M_PI_F;

    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint w = inTexB.get_width();
    uint h = inTexB.get_height();
    float aspect = float(w) / float(h);
    
    float rot = in.rot * pi * 2;
    
    float4 ca = inTexA.sample(s, uv);
    
//    // Kernels
//    switch (int(in.mode)) {
//        case 2: // Add
//            return ca;
//        case 3: // Mult
//            return ca;
//        case 5: // Sub
//            return ca;
//    }
    
    uint aw = inTexA.get_width();
    uint ah = inTexA.get_height();
    uint bw = inTexB.get_width();
    uint bh = inTexB.get_height();
    float2 uvp = place(int(in.place), uv, aw, ah, bw, bh);
    
    // CHECK change to a
    float4 cb;
    if (in.transform) {
        float2 size = float2(in.sx * in.s, in.sy * in.s);
        float x = (uvp.x - 0.5) * aspect - in.tx;
        float y = uvp.y - 0.5 + in.ty;
        float ang = atan2(y, x) - rot;
        float amp = sqrt(pow(x, 2) + pow(y, 2));
        float2 buv = float2((cos(ang) / aspect) * amp, sin(ang) * amp) / size + 0.5;
        cb = inTexB.sample(s, buv);
    } else {
        cb = inTexB.sample(s, uvp);
    }
    
    float4 c = blend(int(in.mode), ca, cb);
    
    return c;
}
