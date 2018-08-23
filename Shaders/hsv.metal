//
//  hsv.metal
//  PixelsShaders
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "hsv_header.metal"

float3 rgb2hsv(float r, float g, float b) {
    float h, s, v;
    float mn, mx, d;
    mn = r < g ? r : g;
    mn = mn < b ? mn : b;
    mx = r > g ? r : g;
    mx = mx > b ? mx : b;
    v = mx;
    d = mx - mn;
    if (d < 0.00001) {
        s = 0;
        h = 0;
        return float3(h, s, v);
    }
    if (mx > 0.0) {
        s = (d / mx);
    } else {
        s = 0.0;
        h = 0.0;
        return float3(h, s, v);
    }
    if (r >= mx) {
        h = (g - b ) / d;
    } else if (g >= mx) {
        h = 2.0 + ( b - r ) / d;
    } else {
        h = 4.0 + ( r - g ) / d;
    }
    h *= 60.0;
    if(h < 0.0) {
        h += 360.0;
    }
    return float3(h, s, v);
}

float3 hsv2rgb(float h, float s, float v) {
    float hh, p, q, t, ff;
    int i;
    float3 c;
    if (s <= 0.0) {
        c.r = v;
        c.g = v;
        c.b = v;
        return c;
    }
    hh = h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = int(hh);
    ff = hh - i;
    p = v * (1.0 - s);
    q = v * (1.0 - (s * ff));
    t = v * (1.0 - (s * (1.0 - ff)));
    switch(i) {
        case 0:
            c.r = v;
            c.g = t;
            c.b = p;
            break;
        case 1:
            c.r = q;
            c.g = v;
            c.b = p;
            break;
        case 2:
            c.r = p;
            c.g = v;
            c.b = t;
            break;
            
        case 3:
            c.r = p;
            c.g = q;
            c.b = v;
            break;
        case 4:
            c.r = t;
            c.g = p;
            c.b = v;
            break;
        case 5:
        default:
            c.r = v;
            c.g = p;
            c.b = q;
            break;
    }
    return c;
}
