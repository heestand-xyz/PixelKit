//
//  noise_header.metal
//

#include <metal_stdlib>
using namespace metal;

#ifndef NOISE
#define NOISE


// Multi-octave Simplex noise
// For each octave, a higher frequency/lower amplitude function will be added to the original.
// The higher the persistence [0-1], the more of each succeeding octave will be added.
float octave_noise_2d(const float octaves,
                      const float persistence,
                      const float scale,
                      const float x,
                      const float y);
float octave_noise_3d(const float octaves,
                      const float persistence,
                      const float scale,
                      const float x,
                      const float y,
                      const float z);
float octave_noise_4d(const float octaves,
                      const float persistence,
                      const float scale,
                      const float x,
                      const float y,
                      const float z,
                      const float w);


// Scaled Multi-octave Simplex noise
// The result will be between the two parameters passed.
float scaled_octave_noise_2d(  const float octaves,
                             const float persistence,
                             const float scale,
                             const float loBound,
                             const float hiBound,
                             const float x,
                             const float y);
float scaled_octave_noise_3d(  const float octaves,
                             const float persistence,
                             const float scale,
                             const float loBound,
                             const float hiBound,
                             const float x,
                             const float y,
                             const float z);
float scaled_octave_noise_4d(  const float octaves,
                             const float persistence,
                             const float scale,
                             const float loBound,
                             const float hiBound,
                             const float x,
                             const float y,
                             const float z,
                             const float w);

// Scaled Raw Simplex noise
// The result will be between the two parameters passed.
float scaled_raw_noise_2d( const float loBound,
                          const float hiBound,
                          const float x,
                          const float y);
float scaled_raw_noise_3d( const float loBound,
                          const float hiBound,
                          const float x,
                          const float y,
                          const float z);
float scaled_raw_noise_4d( const float loBound,
                          const float hiBound,
                          const float x,
                          const float y,
                          const float z,
                          const float w);


// Raw Simplex noise - a single noise value.
float raw_noise_2d(const float x, const float y);
float raw_noise_3d(const float x, const float y, const float z);
float raw_noise_4d(const float x, const float y, const float, const float w);

float dot(constant int g[2], const float x, const float y);
float dot(constant int g[3], const float x, const float y, const float z);
float dot(constant int g[4], const float x, const float y, const float z, const float w);


#endif

