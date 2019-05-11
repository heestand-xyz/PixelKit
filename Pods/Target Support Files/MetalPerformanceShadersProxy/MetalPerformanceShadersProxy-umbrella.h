#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Defines.h"
#import "MetalPerformanceShadersProxy.h"
#import "CGBase.h"
#import "CVMetalTexture.h"
#import "CVMetalTextureCache.h"
#import "ErrorDefines.h"
#import "Includes.h"
#import "MetalPerformanceShadersStub.h"
#import "CAMetalDrawable.h"

FOUNDATION_EXPORT double MetalPerformanceShadersProxyVersionNumber;
FOUNDATION_EXPORT const unsigned char MetalPerformanceShadersProxyVersionString[];

