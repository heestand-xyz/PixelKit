//
//  gradient.metal
//  Shaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "gradient_header.metal"

FractionAndZero fractionAndZero(float fraction, int extend) {
   
    bool zero = false;
    switch (extend) {
        case 0: // Hold
            if (fraction < 0.0001) {
                fraction = 0.0001;
            } else if (fraction > 0.9999) {
                fraction = 0.9999;
            }
            break;
        case 1: // Zero
            if (fraction < 0) {
                zero = true;
            } else if (fraction > 1) {
                zero = true;
            }
            break;
        case 2: // Repeat
            fraction = fraction - floor(fraction);
            break;
        case 3: // Mirror
            bool mirror = false;
            if (fraction > 0 ? int(fraction) % 2 == 1 : int(fraction) % 2 == 0) {
                mirror = true;
            }
            fraction = fraction - floor(fraction);
            if (mirror) {
                fraction = 1.0 - fraction;
            }
            break;
    }
    
    FractionAndZero fz = FractionAndZero();
    fz.zero = zero;
    fz.fraction = fraction;
    
    return fz;
    
}

float4 gradient(float fraction, array<ColorStopArray, ARRMAX> inArr, array<bool, ARRMAX> inArrActive) {
    
    array<ColorStop, 7> color_stops;
    for (int i = 0; i < 7; ++i) {
        ColorStop color_stop = ColorStop();
        color_stop.enabled = inArrActive[i];
        color_stop.position = inArr[i].fraction;
        color_stop.color = float4(inArr[i].cr, inArr[i].cg, inArr[i].cb, inArr[i].ca);
        color_stops[i] = color_stop;
    }

    ColorStop low_color_stop;
    bool low_color_stop_set = false;
    ColorStop high_color_stop;
    bool high_color_stop_set = false;
    for (int i = 0; i < 7; ++i) {
        if (color_stops[i].enabled && color_stops[i].position <= fraction && (!low_color_stop_set || color_stops[i].position > low_color_stop.position)) {
            low_color_stop = color_stops[i];
            low_color_stop_set = true;
        }
        if (color_stops[i].enabled && color_stops[i].position >= fraction && (!high_color_stop_set || color_stops[i].position < high_color_stop.position)) {
            high_color_stop = color_stops[i];
            high_color_stop_set = true;
        }
    }

    float stop_fraction = (fraction - low_color_stop.position) / (high_color_stop.position - low_color_stop.position);

    if (stop_fraction < 0) {
        stop_fraction = 0.0;
    } else if (stop_fraction > 1) {
        stop_fraction = 1.0;
    }

    float4 c = mix(low_color_stop.color, high_color_stop.color, stop_fraction);
    
    return c;
    
}
