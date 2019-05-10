//
//  QuadVTX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-07-24.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float2 position;
    packed_float2 texCoord;
};

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut quadVTX(const device VertexIn* vertex_array [[ buffer(0) ]],
                         unsigned int vid [[ vertex_id ]]) {
    
    VertexIn vertex_in = vertex_array[vid];
    
    VertexOut vertex_out;
    vertex_out.position = float4(vertex_in.position[0], vertex_in.position[1], 0, 1);
    vertex_out.texCoord = vertex_in.texCoord;
    
    return vertex_out;
}
