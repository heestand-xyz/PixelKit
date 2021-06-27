//
//  EffectSingleConvertPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-04-25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float mode;
    float rx;
    float ry;
};

float2 domeToEqui(float2 uv) {
    float pi = M_PI_F;
    float rad = uv.y;
    float ang = uv.x * pi * 2;
    return float2(0.5 + cos(ang) * rad, 0.5 - sin(ang) * rad);
}

float2 equiToDome(float2 uv, float rx, float ry) {
//    float pi = M_PI_F;
//    float theta = uv.x * pi * 2;
////    theta *= 0.25;
//    float phi = ((1.0 - uv.y) * pi) + pi / 2;
////    phi *= 0.25;
//    float x = cos(phi) * sin(theta);
//    float y = sin(phi);
//    float z = cos(phi) * cos(theta);
////    float x = sin(theta) * cos(phi);
////    float y = sin(theta) * sin(phi);
////    float z = cos(theta);
//    float u = atan2(x, z) / (2 * pi) + 0.5;
//    float v = y * 0.5 + 0.5;
////    u += rx * pi;
////    v += ry * pi;
////    float r = atan2(sqrt(x*x+y*y),z) / (pi * rx * 4);
////    float phi2 = atan2(y,x);
////    float u = r * cos(phi2) + 0.5;
////    float v = r * sin(phi2) + 0.5;
//    return float2(u, v);
    float pi = M_PI_F;
    float rad = sqrt(pow(uv.x - 0.5, 2) + pow(uv.y - 0.5, 2)) / 2 + 0.25;
    float ang = 1.0 - (atan2(uv.y - 0.5, uv.x - 0.5) / (pi * 2) + 0.25);
    if (ang > 1) {
        ang -= 1;
    }
    return float2(ang, rad);
}

// https://stackoverflow.com/a/32391780
float2 squareToCircle(float2 uv) {
    float u = uv.x * 2 - 1;
    float v = uv.y * 2 - 1;
    float x1 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) + 2.0 * u * sqrt(2.0), 0.0));
    float x2 = 0.5 * sqrt(max(2.0 + pow(u, 2.0) - pow(v, 2.0) - 2.0 * u * sqrt(2.0), 0.0));
    float x = x1 - x2;
    float y1 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) + 2.0 * v * sqrt(2.0), 0.0));
    float y2 = 0.5 * sqrt(max(2.0 - pow(u, 2.0) + pow(v, 2.0) - 2.0 * v * sqrt(2.0), 0.0));
    float y = y1 - y2;
    return float2(x, y) / 2 + 0.5;
}
float2 circleToSquare(float2 uv) {
    float u = uv.x * 2 - 1;
    float v = uv.y * 2 - 1;
    float x = u * sqrt(1 - 0.5 * pow(v, 2));
    float y = v * sqrt(1 - 0.5 * pow(u, 2));
    return float2(x, y) / 2 + 0.5;
}

float2 cubeToEqui(float2 uv) {
    float pi = M_PI_F;
    float theta = uv.x * pi * 2;
    float phi = ((1.0 - uv.y) * pi) + pi / 2;
    float x = cos(phi) * sin(theta);
    float y = sin(phi);
    float z = cos(phi) * cos(theta);
    float scale;
    float2 px;
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
    return uv;
}

//// https://stackoverflow.com/a/29681646/4586652
//struct CubeSide {
//    int id; // Left Front Right Back Top Bottom
//    float3 pos;
//};
//float cot(float angle) {
//    return 1.0 / tan(angle);
//}
//CubeSide projectTop(float theta, float phi) {
////    float a = 1 / cos(theta);
//    float x = tan(theta) * cos(phi);
//    float y = tan(theta) * sin(phi);
//    float z = 1;
//    CubeSide cubeSide;
//    cubeSide.id = 4;
//    cubeSide.pos = float3(x, y, z);
//    return cubeSide;
//}
//CubeSide projectBottom(float theta, float phi) {
////    float a = -1 / cos(theta);
//    float x = -tan(theta) * cos(phi);
//    float y = -tan(theta) * sin(phi);
//    float z = -1;
//    CubeSide cubeSide;
//    cubeSide.id = 5;
//    cubeSide.pos = float3(x, y, z);
//    return cubeSide;
//}
//CubeSide projectLeft(float theta, float phi) {
//    float x = 1;
//    float y = tan(phi);
//    float z = cot(theta) / cos(phi);
//    if (z < -1) {
//        return projectBottom(theta,phi);
//    }
//    if (z > 1) {
//        return projectTop(theta,phi);
//    }
//    CubeSide cubeSide;
//    cubeSide.id = 0;
//    cubeSide.pos = float3(x, y, z);
//    return cubeSide;
//}
//CubeSide projectFront(float theta, float phi) {
//    float pi = M_PI_F;
//    float x = tan(phi-pi/2);
//    float y = 1;
//    float z = cot(theta) / cos(phi-pi/2);
//    if (z < -1) {
//        return projectBottom(theta,phi);
//    }
//    if (z > 1) {
//        return projectTop(theta,phi);
//    }
//    CubeSide cubeSide;
//    cubeSide.id = 1;
//    cubeSide.pos = float3(x, y, z);
//    return cubeSide;
//}
//CubeSide projectRight(float theta, float phi) {
//    float x = -1;
//    float y = tan(phi);
//    float z = -cot(theta) / cos(phi);
//    if (z < -1) {
//        return projectBottom(theta,phi);
//    }
//    if (z > 1) {
//        return projectTop(theta,phi);
//    }
//    CubeSide cubeSide;
//    cubeSide.id = 2;
//    cubeSide.pos = float3(x, -y, z);
//    return cubeSide;
//}
//CubeSide projectBack(float theta, float phi) {
//    float pi = M_PI_F;
//    float x = tan(phi-3*pi/2);
//    float y = -1;
//    float z = cot(theta) / cos(phi-3*pi/2);
//    if (z < -1) {
//        return projectBottom(theta,phi);
//    }
//    if (z > 1) {
//        return projectTop(theta,phi);
//    }
//    CubeSide cubeSide;
//    cubeSide.id = 3;
//    cubeSide.pos = float3(-x, y, z);
//    return cubeSide;
//}
//CubeSide projection(float theta, float phi) {
//    float pi = M_PI_F;
//    if (theta<0.615) {
//        return projectTop(theta,phi);
//    } else if (theta>2.527) {
//        return projectBottom(theta,phi);
//    } else if (phi <= pi/4 or phi > 7*pi/4) {
//        return projectLeft(theta,phi);
//    } else if (phi > pi/4 and phi <= 3*pi/4) {
//        return projectFront(theta,phi);
//    } else if (phi > 3*pi/4 and phi <= 5*pi/4) {
//        return projectRight(theta,phi);
//    } else if (phi > 5*pi/4 and phi <= 7*pi/4) {
//        return projectBack(theta,phi);
//    }
//    CubeSide cubeSide;
//    cubeSide.id = -1;
//    return cubeSide;
//}
//float2 cubeToImg(CubeSide coords) {
//    float2 xy = 0;
//    float2 side = float2(1.0 / 4.0, 1.0 / 3.0);
//    if (coords.id == 0) { // Left
//        xy = float2(side.x*(coords.pos.y+1)/2, side.y*(3-coords.pos.z)/2);
//    } else if (coords.id == 1) { // Front
//        xy = float2(side.x*(coords.pos.x+3)/2, side.y*(3-coords.pos.z)/2);
//    } else if (coords.id == 2) { // Right
//        xy = float2(side.x*(5-coords.pos.y)/2, side.y*(3-coords.pos.z)/2);
//    } else if (coords.id == 3) { // Back
//        xy = float2(side.x*(7-coords.pos.x)/2, side.y*(3-coords.pos.z)/2);
//    } else if (coords.id == 4) { // Top
//        xy = float2(side.x*(3-coords.pos.x)/2, side.y*(1+coords.pos.y)/2);
//    } else if (coords.id == 5) { // Bottom
//        xy = float2(side.x*(3-coords.pos.x)/2, side.y*(5-coords.pos.y)/2);
//    }
//    return xy;
//}
//float2 equiToCube(float2 uv) {
//    float pi = M_PI_F;
//    float phi = uv.x * 2 * pi;
//    float theta = uv.y * pi;
//    CubeSide proj = projection(theta, phi);
//    if (proj.id == -1) {
//        return float2(-1, -1);
//    }
//    float2 xy = cubeToImg(proj);
//    return xy;
//}

//// get x,y,z coords from out image pixels coords
//// i,j are pixel coords
//// faceIdx is face number
//// faceSize is edge length
//float3 outImgToXYZ(float i, float j, int faceIdx, float2 faceSize) {
//    float a = 2.0 * float(i) / faceSize;
//    float b = 2.0 * float(j) / faceSize;
//    if (faceIdx == 0) { // back
//        return float3(-1.0, 1.0 - a, 1.0 - b);
//    } else if faceIdx == 1) { // left
//        return float3(a - 1.0, -1.0, 1.0 - b);
//    } else if faceIdx == 2) { // front
//        return float3(1.0, a - 1.0, 1.0 - b);
//    } else if faceIdx == 3) { // right
//        return float3(1.0 - a, 1.0, 1.0 - b);
//    } else if faceIdx == 4) { // top
//        return float3(b - 1.0, a - 1.0, 1.0);
//    } else if faceIdx == 5) { // bottom
//        return float3(1.0 - b, a - 1.0, -1.0);
//    }
//    return float3(0);
//}
//
//// convert using an inverse transformation
//float2 convertFace(float2 uv, int faceIdx) {
//    float2 inSize = imgIn.size
//    outSize = imgOut.size
//    inPix = imgIn.load()
//    outPix = imgOut.load()
//    faceSize = outSize[0]
//
//    for xOut in xrange(faceSize):
//    for yOut in xrange(faceSize):
//    (x,y,z) = outImgToXYZ(xOut, yOut, faceIdx, faceSize)
//    theta = atan2(y,x) // range -pi to pi
//    r = hypot(x,y)
//    phi = atan2(z,r) // range -pi/2 to pi/2
//
//    // source img coords
//    uf = 0.5 * inSize[0] * (theta + pi) / pi
//    vf = 0.5 * inSize[0] * (pi/2 - phi) / pi
//
//    // Use bilinear interpolation between the four surrounding pixels
//    ui = floor(uf)  // coord of pixel to bottom left
//    vi = floor(vf)
//    u2 = ui+1       // coords of pixel to top right
//    v2 = vi+1
//    mu = uf-ui      // fraction of way across pixel
//    nu = vf-vi
//
//    // Pixel values of four corners
//    A = inPix[ui % inSize[0], clip(vi, 0, inSize[1]-1)]
//    B = inPix[u2 % inSize[0], clip(vi, 0, inSize[1]-1)]
//    C = inPix[ui % inSize[0], clip(v2, 0, inSize[1]-1)]
//    D = inPix[u2 % inSize[0], clip(v2, 0, inSize[1]-1)]
//
//    // interpolate
//    (r,g,b) = (
//               A[0]*(1-mu)*(1-nu) + B[0]*(mu)*(1-nu) + C[0]*(1-mu)*nu+D[0]*mu*nu,
//               A[1]*(1-mu)*(1-nu) + B[1]*(mu)*(1-nu) + C[1]*(1-mu)*nu+D[1]*mu*nu,
//               A[2]*(1-mu)*(1-nu) + B[2]*(mu)*(1-nu) + C[2]*(1-mu)*nu+D[2]*mu*nu )
//
//    outPix[xOut, yOut] = (int(round(r)), int(round(g)), int(round(b)))
//
//
//
//
//imgIn = Image.open(sys.argv[1])
//inSize = imgIn.size
//faceSize = inSize[0] / 4
//components = sys.argv[1].rsplit('.', 2)
//
////FACE_NAMES = {
////    0: 'back',
////    1: 'left',
////    2: 'front',
////    3: 'right',
////    4: 'top',
////    5: 'bottom'
////}

//float2 equiToCube(float2 uv) {
//    //for face in xrange(6):
//    //imgOut = Image.new("RGB", (faceSize, faceSize), "black")
//    //convertFace(imgIn, imgOut, face)
//    //imgOut.save(components[0] + "_" + FACE_NAMES[face] + "." + components[1])
//    return uv;
//}

fragment float4 effectSingleConvertPIX(VertexOut out [[stage_in]],
                                       texture2d<float>  inTex [[ texture(0) ]],
                                       const device Uniforms& in [[ buffer(0) ]],
                                       sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
//    v = 1 - v; // Content Flip Fix A
    float2 uv = float2(u, v);
    
    switch (int(in.mode)) {
        case 0: // domeToEqui
            uv = domeToEqui(uv);
            break;
        case 1: // equiToDome
            uv = equiToDome(uv, in.rx, in.ry);
            break;
        case 2: // cubeToEqui
            uv = cubeToEqui(uv);
            break;
//        case 3: // equiToCube
//            uv = equiToCube(uv);
//            break;
        case 4: // squareToCircle
            uv = squareToCircle(uv);
            break;
        case 5: // circleToSquare
            uv = circleToSquare(uv);
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
//        case 3: // equiToCube
//            if (uv.x == -1 && uv.y == -1) {
//                c = 0;
//            }
//            break;
    }
    
    return c;
}
