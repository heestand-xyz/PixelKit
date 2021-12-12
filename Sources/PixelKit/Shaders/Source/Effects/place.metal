//
//  place.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "place_header.metal"

float2 place(int place, float2 uv, uint aw, uint ah, uint bw, uint bh) {
   
    float aspect_a = float(aw) / float(ah);
    float aspect_b = float(bw) / float(bh);
    float bu = uv.x;
    float bv = uv.y;
    switch (place) {
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
        case 3: // Center
            bu = 0.5 + ((uv.x - 0.5) * aw) / bw;
            bv = 0.5 + ((uv.y - 0.5) * ah) / bh;
            break;
    }
    
    return float2(bu, bv);
    
}
