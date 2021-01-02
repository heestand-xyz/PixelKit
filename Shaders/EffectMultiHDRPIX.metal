//
//  EffectMultiHDRPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2020-06-20.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float evLow;
    float evHigh;
};

fragment float4 effectMultiHDRPIX(VertexOut out [[stage_in]],
                                  texture2d_array<float>  inTexs [[ texture(0) ]],
                                  const device Uniforms& in [[ buffer(0) ]],
                                  sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    uint count = inTexs.get_array_size();
    
    if (count == 0) {
        return 0;
    }
    
    float4 low = inTexs.sample(s, uv, 0);
    float4 mid = inTexs.sample(s, uv, 1);
    float4 high = inTexs.sample(s, uv, 2);
    
//    if (u < 0.5) {
//        if (v < 1.0 / 3.0) {
//            return low;
//        } else if (v < 2.0 / 3.0) {
//            return mid;
//        } else {
//            return high;
//        }
//    }
    
    float multLow = 1.0 / pow(2.0, -in.evLow); // -1.0 : 0.5
    float multHigh = pow(2.0, 1.0 / in.evHigh); // 2.0 : 4.0
    
    float4 final = 0.0;
    if (u < 1.0 / 3.0) {
        if (v < 1.0 / 3.0) {
            final = mid * multLow;
        } else if (v < 2.0 / 3.0) {
            final = low;
        } else {
            final = low / multLow;
        }
    } else if (u < 2.0 / 3.0) {
        final = mid;
    } else {
        if (v < 1.0 / 3.0) {
            final = mid * multHigh;
        } else if (v < 2.0 / 3.0) {
            final = high;
        } else {
            final = high / multHigh;
        }
    }
    
//    float4 c = float4(float3(final.r + final.g + final.b) / 3.0, 1.0);
    float4 c = float4(final.rgb, 1.0);
    
//    float4 c = 0;
//    for (uint i = 0; i < count; ++i) {
//        float4 ci = inTexs.sample(s, uv, i);
//        float exposure = 0.0;
//        switch (i) {
//            case 0:
//                exposure = in.exposureLow;
//                break;
//            case 1:
//                exposure = in.exposureMid;
//                break;
//            case 2:
//                exposure = in.exposureHigh;
//                break;
//        }
//        c += ci;
//    }
//    c /= float(count);
    
    return c;
}
