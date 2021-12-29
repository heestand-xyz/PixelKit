//
//  EffectMultiBlendsPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../../Shaders/Source/Effects/blend_header.metal"

constant int PARTICLE_MAX_COUNT = 1000;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float backgroundColorRed;
    float backgroundColorGreen;
    float backgroundColorBlue;
    float backgroundColorAlpha;
    float blendMode;
    float particleScale;
    float aspect;
};

struct Particle {
    float x;
    float y;
    float i;
};

fragment float4 textureParticlesPIX(VertexOut out [[stage_in]],
                                    texture2d_array<float> textures [[ texture(0) ]],
                                    const device Uniforms& uniforms [[ buffer(0) ]],
                                    const device array<Particle, PARTICLE_MAX_COUNT>& particles [[ buffer(1) ]],
                                    const device array<bool, PARTICLE_MAX_COUNT>& particlesActive [[ buffer(2) ]],
                                    sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint count = textures.get_array_size();
    
    float4 backgroundColor = float4(uniforms.backgroundColorRed,
                                    uniforms.backgroundColorGreen,
                                    uniforms.backgroundColorBlue,
                                    uniforms.backgroundColorAlpha);
    
    float4 color = 0.0;
    
    for (int i = 0; i < PARTICLE_MAX_COUNT; i++) {
        
        if (!particlesActive[i]) {
            break;
        }
        
        Particle particle = particles[i];
        
        int nextIndex = int(particle.i);
        float2 nextUV = float2(((u - 0.5) * uniforms.aspect - particle.x) / uniforms.particleScale + 0.5,
                               (v - 0.5 + particle.y) / uniforms.particleScale + 0.5);
        float4 nextColor = textures.sample(s, nextUV, nextIndex);
        
        color = blend(int(uniforms.blendMode), color, nextColor);
    }
    
    return blendOver(backgroundColor, color);
}
