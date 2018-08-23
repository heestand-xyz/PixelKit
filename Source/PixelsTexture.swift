//
//  PixelsTexture.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

extension Pixels {
    
    func makeTexture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache!, pixelBuffer, nil, PIX.Color.Bits._8.mtl, width, height, 0, &cvTextureOut) // CHECK add high bit support
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            log(.error, .engine, "Textrue: Creation failed.")
            return nil
        }
        return inputTexture
    }
    
    func copyTexture(from pix: PIX) -> MTLTexture? {
        guard pix.texture != nil else { return nil }
        guard let textureCopy = emptyTexture(size: CGSize(width: pix.texture!.width, height: pix.texture!.height)) else { return nil }
        let commandBuffer = commandQueue!.makeCommandBuffer()!
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return nil }
        blitEncoder.copy(from: pix.texture!, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: pix.texture!.width, height: pix.texture!.height, depth: 1), to: textureCopy, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    func emptyTexture(size: CGSize) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: colorBits.mtl, width: Int(size.width), height: Int(size.height), mipmapped: true)
        return metalDevice!.makeTexture(descriptor: descriptor)
    }
    
    func makeMultiTexture(from textures: [MTLTexture], with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        guard !textures.isEmpty else {
            log(.error, .texture, "Multi texture needs at least one texture.")
            return nil
        }
        
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = colorBits.mtl
        descriptor.textureType = .type2DArray
        descriptor.width = textures.first!.width
        descriptor.height = textures.first!.height
        descriptor.arrayLength = textures.count
        
        guard let texture = metalDevice!.makeTexture(descriptor: descriptor) else {
            log(.error, .texture, "Multi Texture: Texture creation failed.")
            return nil
        }

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            log(.error, .texture, "Multi Texture: Blit Encoder creation failed.")
            return nil
        }
        for (i, iTexture) in textures.enumerated() {
            blitEncoder.copy(from: iTexture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: iTexture.width, height: iTexture.height, depth: 1), to: texture, destinationSlice: i, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        }
        blitEncoder.endEncoding()
        
        return texture
    }
    
}
