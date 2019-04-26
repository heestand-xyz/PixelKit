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

// https://stackoverflow.com/a/29681646/4586652
//float cot(float angle) {
//    return 1.0 / tan(angle);
//}
//float projection(float theta, float phi) {
//    if (theta<0.615) {
//        return projectTop(theta,phi)
//    } else if (theta>2.527) {
//        return projectBottom(theta,phi)
//    } else if (phi <= pi/4 or phi > 7*pi/4) {
//        return projectLeft(theta,phi)
//    } else if (phi > pi/4 and phi <= 3*pi/4) {
//        return projectFront(theta,phi)
//    } else if (phi > 3*pi/4 and phi <= 5*pi/4) {
//        return projectRight(theta,phi)
//    } else if (phi > 5*pi/4 and phi <= 7*pi/4) {
//        return projectBack(theta,phi)
//    }
//}
//float projectLeft(float theta, float phi) {
//    x = 1
//    y = tan(phi)
//    z = cot(theta) / cos(phi)
//    if z < -1 {
//        return projectBottom(theta,phi)
//    }
//    if z > 1 {
//    return projectTop(theta,phi)
//    return ("Left",x,y,z)
//}
//float projectFront(float theta, float phi) {
//    x = tan(phi-pi/2)
//    y = 1
//    z = cot(theta) / cos(phi-pi/2)
//    if z < -1 {
//    return projectBottom(theta,phi)
//    if z > 1 {
//    return projectTop(theta,phi)
//    return ("Front",x,y,z)
//}
//float projectRight(float theta, float phi) {
//    x = -1
//    y = tan(phi)
//    z = -cot(theta) / cos(phi)
//    if z < -1 {
//    return projectBottom(theta,phi)
//    if z > 1 {
//    return projectTop(theta,phi)
//    return ("Right",x,-y,z)
//    }
//float projectBack(float theta, float phi) {
//    x = tan(phi-3*pi/2)
//    y = -1
//    z = cot(theta) / cos(phi-3*pi/2)
//    if z < -1 {
//    return projectBottom(theta,phi)
//    if z > 1 {
//    return projectTop(theta,phi)
//    return ("Back",-x,y,z)
//    }
//float projectTop(float theta, float phi) {
//    a = 1 / cos(theta)
//    x = tan(theta) * cos(phi)
//    y = tan(theta) * sin(phi)
//    z = 1
//    return ("Top",x,y,z)
//}
//float projectBottom(float theta, float phi) {
//    a = -1 / cos(theta)
//    x = -tan(theta) * cos(phi)
//    y = -tan(theta) * sin(phi)
//    z = -1
//    return ("Bottom",x,y,z)
//}

fragment float4 effectSingleConvertPIX(VertexOut out [[stage_in]],
                                       texture2d<float>  inTex [[ texture(0) ]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
//    v = 1 - v; // Content Flip Fix A
    float2 uv = float2(u, v);
    
    // domeToEqui
    float er = v;
    float ea = u * pi * 2;
    
    // equiToDome
    float rv = sqrt(pow(u - 0.5, 2) + pow(v - 0.5, 2)) / 2 + 0.25;
    float au = 1.0 - (atan2(v - 0.5, u - 0.5) / (pi * 2) + 0.25);
    if (au > 1) {
        au -= 1;
    }

    // cubeToEqui
    float theta = u * pi * 2;
    float phi = ((1.0 - v) * pi) + pi / 2;
    float x = cos(phi) * sin(theta);
    float y = sin(phi);
    float z = cos(phi) * cos(theta);
    float scale;
    float2 px;
    
    switch (int(in.mode)) {
        case 0: // domeToEqui
            uv = float2(0.5 + cos(ea) * er, 0.5 - sin(ea) * er);
            break;
        case 1: // equiToDome
            uv = float2(au, rv);
            break;
        case 2: // cubeToEqui
            if (abs(x) >= abs(y) && abs(x) >= abs(z)) {
                if (x < 0.0) { // Left
                    scale = -1.0 / x;
                    px.x = ( z*scale + 1.0) / 2.0;
                    px.y = ( y*scale + 1.0) / 2.0;
                    uv = float2(px.x / 4, (px.y + 1) / 3 + 1 / 3);
                }
                else { // Right
                    scale = 1.0 / x;
                    px.x = (-z*scale + 1.0) / 2.0;
                    px.y = ( y*scale + 1.0) / 2.0;
                    uv = float2((px.x + 2) / 4 + 2 / 4, (px.y + 1) / 3 + 1 / 3);
                }
            }
            else if (abs(y) >= abs(z)) {
                if (y < 0.0) { // Top
                    scale = -1.0 / y;
                    px.x = ( x*scale + 1.0) / 2.0;
                    px.y = ( z*scale + 1.0) / 2.0;
                    uv = float2((px.x + 1) / 4 + 1 / 4, px.y / 3 + 2 / 3);
                }
                else { // Bottom
                    scale = 1.0 / y;
                    px.x = ( x*scale + 1.0) / 2.0;
                    px.y = (-z*scale + 1.0) / 2.0;
                    uv = float2((px.x + 1) / 4 + 1 / 4, (px.y + 2) / 3);
                }
            }
            else {
                if (z < 0.0) { // Back
                    scale = -1.0 / z;
                    px.x = (-x*scale + 1.0) / 2.0;
                    px.y = ( y*scale + 1.0) / 2.0;
                    uv = float2((px.x + 3) / 4 + 3 / 4, (px.y + 1) / 3 + 1 / 3);
                }
                else { // Front
                    scale = 1.0 / z;
                    px.x = ( x*scale + 1.0) / 2.0;
                    px.y = ( y*scale + 1.0) / 2.0;
                    uv = float2((px.x + 1) / 4 + 1 / 4, (px.y + 1) / 3 + 1 / 3);
                }
            }
            break;
        case 3: // equiToCube
            
            
            break;
        case 4: // squareToCircle
            uv = squareToCircle(u * 2 - 1, v * 2 - 1) / 2 + 0.5;
            break;
        case 5: // circleToSquare
            uv = circleToSquare(u * 2 - 1, v * 2 - 1) / 2 + 0.5;
            break;
    }
    
    float4 c = inTex.sample(s, uv);
    
    switch (int(in.mode)) {
        case 0: // domeToEqui
            if (v > 0.5) {
                c = 0;
            }
            break;
        case 1: // equiToDome
            if (sqrt(pow(u - 0.5, 2) + pow(v - 0.5, 2)) > 0.5) {
                c = 0;
            }
            break;
    }
    
    return c;
}
