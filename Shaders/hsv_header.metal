//
//  hsv_header.metal
//  PixelsShaders
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

#ifndef HSV
#define HSV

float3 rgb2hsv(float r, float g, float b);
float3 hsv2rgb(float h, float s, float v);

#endif
