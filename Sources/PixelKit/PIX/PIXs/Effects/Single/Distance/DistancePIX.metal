//
//  DistancePIX.metal
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-16.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float style;
    float count;
    float dist;
    float threshold;
    float brightness;
};

fragment float4 distancePIX(VertexOut out [[stage_in]],
                            texture2d<float>  inTex [[ texture(0) ]],
                            const device Uniforms& in [[ buffer(0) ]],
                            sampler s [[ sampler(0) ]]) {
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    uint iw = inTex.get_width();
    uint ih = inTex.get_height();
    float aspect = float(iw) / float(ih);
    
//    int style = int(in.style);
    int angleCount = int(in.count);
    if (angleCount > 128) {
        angleCount = 128;
    }
    float dist = in.dist;
    int maxCount = 512;
    float threshold = in.threshold;
    float brightness = in.brightness;
    
    float4 color = float4(float3(0.0), 1.0);
    
    bool isDone = false;
    
    for (int rayIndex = 0; rayIndex <= maxCount; rayIndex++) {
        
        if (isDone) {
            break;
        }
        
        float rayDist = float(rayIndex) * dist;
        
        for (int angleIndex = 0; angleIndex <= angleCount; angleIndex++) {
            
            float angleFraction = float(angleIndex) / float(angleCount);
            float angle = angleFraction * pi * 2.0 + pi / 2;
            
            float x = cos(angle) * rayDist / aspect;
            float y = sin(angle) * rayDist;
            
            float2 offset = float2(x, y);
            
            float2 sampleUV = uv + offset;
            
            if (sampleUV.x < 0.0 || sampleUV.y < 0.0) {
                continue;
            } else if (sampleUV.x > 1.0 || sampleUV.y > 1.0) {
                continue;
            }
            
            float4 sampleColor = inTex.sample(s, sampleUV);
            float sampleLight = (sampleColor.r + sampleColor.g + sampleColor.b) / 3;
            
            if (sampleLight > threshold) {
                color = float4(float3(1.0 - rayDist / brightness), 1.0);
                isDone = true;
                break;
            }
            
        }
        
    }
    
    return color;
}
