//
//  EffectMergerLUTPIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2020-03-22.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float bits;
};

float4 lerpColor(float fraction, float4 ca, float4 cb) {
    return (1.0 - fraction) * ca + fraction * cb;
}

float uvClamp(float val, uint res) {
    return (val * float(res - 1) + 0.5) / float(res);
}

float3 lutmap(float2 uv, uint bits) {
    int res = int(pow(2.0, float(bits)));
    int ires = int(sqrt(float(res)));
    int raw = ires * ires;
    int xyres = raw * ires;
    int x = int(uv.x * float(xyres));
    int y = int(uv.y * float(xyres));
    float _u = float(x % raw) / float(raw - 1);
    float _v = float(y % raw) / float(raw - 1);
    int ix = int(uv.x * float(ires));
    int iy = int(uv.y * float(ires));
    int iw = iy * ires + ix;
    float _w = float(iw) / float(raw - 1);
    return float3(_u, _v, _w);
}

uint3 rgbToXyz(float3 c, uint count, bool bx, bool by, bool bz) {
    float fx = c.r * float(count - 1);
    float fy = c.g * float(count - 1);
    float fz = c.b * float(count - 1);
    uint x = uint(bx ? ceil(fx) : fx);
    uint y = uint(by ? ceil(fy) : fy);
    uint z = uint(bz ? ceil(fz) : fz);
    return uint3(x, y, z);
}

//uint2 xyzToXy(uint3 i, uint cres, uint ires) {
//
//    uint sx = i.z % ires;
//    uint sy = i.z / ires;
//    uint x = sx * cres + i.x;
//    uint y = sy * cres + i.y;
//
//    return uint2(x, y);
//}
//
//float2 xyToUv(uint2 i, uint bres, uint ares) {
//
//    float lu = (float(i.x) + 0.5) / float(bres);
//    float lv = (float(i.y) + 0.5) / float(bres);
//
//    lv = 1.0 - lv; // Content Flip Fix
//
//    return float2(lu, lv);
//}

float2 xyzToUv(uint3 i, uint cres, uint ires) {
    
//    return float2(i.z == 251, ires == 16);
    
    uint wix = i.z % ires;
    uint wiy = i.z / ires;
    
//    return float2(wix, ires - wiy) / float(ires);
    
    float xx = float(i.x) / float(cres - 1);
    float yy = float(i.y) / float(cres - 1);
    
    // workaround
//    float cx = uvClamp(xx, ires);
//    float cy = uvClamp(yy, ires);
    // technically correct
    float cx = uvClamp(xx, cres);
    float cy = uvClamp(yy, cres);

    float u = (float(wix) + cx) / float(ires);
    float v = (float(wiy) + cy) / float(ires);

    v = 1.0 - v; // Content Flip Fix

    return float2(u, v);
}

fragment float4 effectMergerLUTPIX(VertexOut out [[stage_in]],
                                   texture2d<float>  inTexA [[ texture(0) ]],
                                   texture2d<float>  inTexB [[ texture(1) ]],
                                   const device Uniforms& in [[ buffer(0) ]],
                                   sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint res = inTexB.get_width();                       // 8bit:4_096       6bit:512      4bit:64     2bit:8
    uint count = uint(pow(float(res), 2));               // 8bit:16_777_216  6bit:262_144  4bit:4_096  2bit:64
    uint cres = uint(round(pow(float(count), 1.0 / 3))); // 8bit:256         6bit:64       4bit:16     2bit:4
    uint ires = uint(sqrt(float(cres)));                 // 8bit:16          6bit:8        4bit:4      2bit:2
    
    uint bits = uint(in.bits); // 8 or 16
    uint bitscres = uint(pow(2, float(bits)));
    bool bitMatch = bitscres == cres;

    float4 ca = inTexA.sample(s, uv);
        
    float3 c = 0;
    if (bitMatch) {
        float3 _rgb = ca.rgb;
        uint3 _xyz = rgbToXyz(_rgb, cres, false, false, false);
        float2 _uv = xyzToUv(_xyz, cres, ires);
//        c = float3(_uv.x, _uv.y, 0);
        c = inTexB.sample(s, _uv).rgb;
    } else {
//        uint3 i000 = rgbToXyz(ca.rgb, cres, false, false, false);
//        uint3 i001 = rgbToXyz(ca.rgb, cres, false, false, true);
//        uint3 i010 = rgbToXyz(ca.rgb, cres, false, true, false);
//        uint3 i011 = rgbToXyz(ca.rgb, cres, false, true, true);
//        uint3 i100 = rgbToXyz(ca.rgb, cres, true, false, false);
//        uint3 i101 = rgbToXyz(ca.rgb, cres, true, false, true);
//        uint3 i110 = rgbToXyz(ca.rgb, cres, true, true, false);
//        uint3 i111 = rgbToXyz(ca.rgb, cres, true, true, true);
//        float2 lut000 = lutCoord(i000, res, cres, ires);
//        float2 lut001 = lutCoord(i001, res, cres, ires);
//        float2 lut010 = lutCoord(i010, res, cres, ires);
//        float2 lut011 = lutCoord(i011, res, cres, ires);
//        float2 lut100 = lutCoord(i100, res, cres, ires);
//        float2 lut101 = lutCoord(i101, res, cres, ires);
//        float2 lut110 = lutCoord(i110, res, cres, ires);
//        float2 lut111 = lutCoord(i111, res, cres, ires);
//        float4 c000 = inTexB.sample(s, lut000);
//        float4 c001 = inTexB.sample(s, lut001);
//        float4 c010 = inTexB.sample(s, lut010);
//        float4 c011 = inTexB.sample(s, lut011);
//        float4 c100 = inTexB.sample(s, lut100);
//        float4 c101 = inTexB.sample(s, lut101);
//        float4 c110 = inTexB.sample(s, lut110);
//        float4 c111 = inTexB.sample(s, lut111);
//        float fx = c.r * float(cres - 1);
//        float fy = c.g * float(cres - 1);
//        float fz = c.b * float(cres - 1);
//        float fu = fx - floor(fx);
//        float fv = fy - floor(fy);
//        float fw = fz - floor(fz);
//        float4 c00 = lerpColor(fw, c000, c001);
//        float4 c01 = lerpColor(fw, c010, c011);
//        float4 c10 = lerpColor(fw, c100, c101);
//        float4 c11 = lerpColor(fw, c110, c111);
//        float4 c0 = lerpColor(fv, c00, c01);
//        float4 c1 = lerpColor(fv, c10, c11);
//        c = lerpColor(fu, c0, c1);
    }
    
//    float fx = ca.r * float(cres);
//    float fy = ca.g * float(cres);
//    float fz = ca.b * float(cres);
//    return float4(fx, floor(fx), ceil(fx), 1);
    
//    return float4(!bitMatch, bitMatch, 0, 1);
    
    return float4(c.r * ca.a, c.g * ca.a, c.b * ca.a, ca.a);
}


