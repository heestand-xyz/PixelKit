//
//  place_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef PLACE
#define PLACE

float2 place(int place, float2 uv, uint aw, uint ah, uint bw, uint bh);

#endif
