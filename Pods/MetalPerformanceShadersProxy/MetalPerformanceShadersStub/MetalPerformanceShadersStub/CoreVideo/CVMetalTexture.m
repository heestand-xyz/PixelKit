//
//  CVMetalTexture.m
//  MetalPerformanceShadersStub
//
//  Created by Santiago Castro on 7/25/17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

#import "Defines.h"

#if STUB_ENABLED

#import "CVMetalTexture.h"

CFTypeID CVMetalTextureGetTypeID(void) {
    STUB_NOT_IMPLEMENTED
}

id <MTLTexture> CV_NULLABLE CVMetalTextureGetTexture(CVMetalTextureRef image) {
    STUB_NOT_IMPLEMENTED
}

Boolean CVMetalTextureIsFlipped(CVMetalTextureRef image) {
    STUB_NOT_IMPLEMENTED
}

void CVMetalTextureGetCleanTexCoords(CVMetalTextureRef image, float *lowerLeft, float *lowerRight, float *upperRight, float *upperLeft) {
    STUB_NOT_IMPLEMENTED
}

#endif
