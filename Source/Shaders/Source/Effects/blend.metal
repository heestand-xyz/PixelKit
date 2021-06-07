//
//  blend.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "blend_header.metal"

float4 lerpColor(float4 fraction, float4 from, float4 to) {
    return from * (1.0 - fraction) + to * fraction;
}

float4 blend(int mode, float4 ca, float4 cb) {
    
    float pi = 3.14159265359;

    float4 c;
    float3 rgb_a = float3(ca);
    float3 rgb_b = float3(cb);
    float aa = max(ca.a, cb.a);
    float ia = min(ca.a, cb.a);
    float oa = ca.a - cb.a;
    float xa = abs(ca.a - cb.a);
    switch (mode) {
        case 0: // Over
            c = float4(rgb_a * (1.0 - cb.a) + rgb_b * cb.a, aa);
            break;
        case 1: // Under
            c = float4(rgb_a * ca.a + rgb_b * (1.0 - ca.a), aa);
            break;
        case 2: // Add Color
            c = float4(rgb_a + rgb_b, aa);
            break;
        case 3: // Add
            c = ca + cb;
            break;
        case 4: // Mult
            c = ca * cb;
            break;
        case 5: // Diff
            c = float4(abs(rgb_a - rgb_b), aa);
            break;
        case 6: // Sub Color
            c = float4(rgb_a - rgb_b, aa);
            break;
        case 7: // Sub
            c = ca - cb;
            break;
        case 8: // Max
            c = max(ca, cb);
            break;
        case 9: // Min
            c = min(ca, cb);
            break;
        case 10: // Gamma
            c = pow(ca, 1 / cb);
            break;
        case 11: // Power
            c = pow(ca, cb);
            break;
        case 12: // Divide
            c = ca / cb;
            break;
        case 13: // Average
            c = ca / 2 + cb / 2;
            break;
        case 14: // Cosine
            c = lerpColor(min(cb.r, 1.0), ca, cos(ca * pi + pi) / 2 + 0.5);
            for (int i = 1; i < int(ceil(cb.r)); i++) {
                c = lerpColor(min(max(cb.r - float(i), 0.0), 1.0), c, cos(c * pi + pi) / 2 + 0.5);
            }
            break;
        case 15: // Inside Source
            c = float4(rgb_a * ia, ia);
            break;
//        case 15: // Inside Destination
//            c = float4(rgb_b * ia, ia);
//            break;
        case 16: // Outside Source
            c = float4(rgb_a * oa, oa);
            break;
//        case 17: // Outside Destination
//            c = float4(rgb_b * oa, oa);
//            break;
        case 17: // XOR
            c = float4(rgb_a * (ca.a * xa) + rgb_b * (cb.a * xa), xa);
            break;
    }
    
    return c;
    
}
   
