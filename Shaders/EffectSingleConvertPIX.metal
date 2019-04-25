//
//  EffectSingleConvertPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2019-04-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float mode;
};

// https://stackoverflow.com/a/32391780

float2 squareToCircle(float u, float v) {
    float x1 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) + 2.0 * u * sqrt(2.0), 0.0));
    float x2 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) - 2.0 * u * sqrt(2.0), 0.0));
    float x = x1 - x2;
    float y1 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) + 2.0 * v * sqrt(2.0), 0.0));
    float y2 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) - 2.0 * v * sqrt(2.0), 0.0));
    float y = y1 - y2;
    return float2(x, y);
}
    
float2 circleToSquare(float u, float v) {
    float x = u * sqrt(1 - 0.5 * pow(v, 2));
    float y = v * sqrt(1 - 0.5 * pow(u, 2));
    return float2(x, y);
}

fragment float4 effectSingleConvertPIX(VertexOut out [[stage_in]],
                                       texture2d<float>  inTex [[ texture(0) ]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix A
    float2 uv = float2(u, v);
    
    float er = v;
    float ea = u * pi * 2;
    
//    float radius = 0.5;
//    float theta = u * pi;
//    float phi = (v * pi) / 2.0;
//    float x = cos(theta) * cos(phi) * radius;
//    float y = sin(theta) * cos(phi) * radius;
//    float z = sin(phi) * radius;
    
//    float dr = sqrt(pow(u - 0.5, 2) + pow(v, 2)) + 0.5;
//    float da = atan2(v, u - 0.5) / (pi * 2);
//    dr = dr - floor(dr);
//    da = da - floor(da);

//    float theta = u * pi;
//    float phi = (v * pi) / 2.0;
//    float x = cos(phi) * sin(theta);
//    float y = sin(phi);
//    float z = cos(phi) * cos(theta);
//    float scale;
//    float2 px;
    
    switch (int(in.mode)) {
        case 0: // domeToEquirectangular
            uv = float2(0.5 + cos(ea) * er, 0.5 + sin(ea) * er);
            break;
//        case 1: // equirectangularToDome
//            uv = float2(x, y);
//            break;
//        case 2: // cubeToEquirectangular
//            if (abs(x) >= abs(y) && abs(x) >= abs(z)) {
//                if (x < 0.0) {
//                    scale = -1.0 / x;
//                    px.x = ( z*scale + 1.0) / 2.0;
//                    px.y = ( y*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4, px.y / 3 + 1 / 3);
////                    src = texture(cubeLeftImage, px);
//                }
//                else {
//                    scale = 1.0 / x;
//                    px.x = (-z*scale + 1.0) / 2.0;
//                    px.y = ( y*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4 + 2 / 4, px.y / 3 + 1 / 3);
////                    src = texture(cubeRightImage, px);
//                }
//            }
//            else if (abs(y) >= abs(z)) {
//                if (y < 0.0) {
//                    scale = -1.0 / y;
//                    px.x = ( x*scale + 1.0) / 2.0;
//                    px.y = ( z*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4 + 1 / 4, px.y / 3 + 2 / 3);
////                    src = texture(cubeTopImage, px);
//                }
//                else {
//                    scale = 1.0 / y;
//                    px.x = ( x*scale + 1.0) / 2.0;
//                    px.y = (-z*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4 + 1 / 4, px.y / 3);
////                    src = texture(cubeBottomImage, px);
//                }
//            }
//            else {
//                if (z < 0.0) {
//                    scale = -1.0 / z;
//                    px.x = (-x*scale + 1.0) / 2.0;
//                    px.y = ( y*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4 + 3 / 4, px.y / 3 + 1 / 3);
////                    src = texture(cubeBackImage, px);
//                }
//                else {
//                    scale = 1.0 / z;
//                    px.x = ( x*scale + 1.0) / 2.0;
//                    px.y = ( y*scale + 1.0) / 2.0;
//                    uv = float2(px.x / 4 + 1 / 4, px.y / 3 + 1 / 3);
////                    src = texture(cubeFrontImage, px);
//                }
//            }
//            break;
        case 4: // squareToCircle
            uv = squareToCircle(u * 2 - 1, v * 2 - 1) / 2 + 0.5;
            break;
        case 5: // circleToSquare
            uv = circleToSquare(u * 2 - 1, v * 2 - 1) / 2 + 0.5;
            break;
    }
    
    float4 c = inTex.sample(s, uv);
    
    return c;
}
