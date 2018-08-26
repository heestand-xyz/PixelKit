//
//  PixelsTexture.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

extension Pixels {
    
    enum TextureError: Error {
        case pixelBuffer
        case empty
        case copy(String)
        case multi(String)
    }
    
    func makeTexture(from pixelBuffer: CVPixelBuffer) throws -> MTLTexture {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, PIX.Color.Bits._8.mtl, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            throw TextureError.pixelBuffer
        }
        return inputTexture
    }
    
    func emptyTexture(size: CGSize) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: colorBits.mtl, width: Int(size.width), height: Int(size.height), mipmapped: true)
        guard let t = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.empty
        }
        return t
    }
    
    func copyTexture(from pix: PIX) throws -> MTLTexture {
        guard let texture = pix.texture else {
            throw TextureError.copy("PIX Texture is nil.")
        }
        let textureCopy = try emptyTexture(size: CGSize(width: pix.texture!.width, height: pix.texture!.height))
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw TextureError.copy("Command Buffer make failed.")
        }
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.copy("Blit Command Encoder make failed.")
        }
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1), to: textureCopy, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    func makeMultiTexture(from textures: [MTLTexture], with commandBuffer: MTLCommandBuffer) throws -> MTLTexture {
        
        guard !textures.isEmpty else {
            throw TextureError.multi("Passed Textures array is empty.")
        }
        
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = colorBits.mtl
        descriptor.textureType = .type2DArray
        descriptor.width = textures.first!.width
        descriptor.height = textures.first!.height
        descriptor.arrayLength = textures.count
        
        guard let multiTexture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.multi("Texture creation failed.")
        }

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.multi("Blit Encoder creation failed.")
        }
        
        for (i, texture) in textures.enumerated() {
            blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1), to: multiTexture, destinationSlice: i, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        }
        blitEncoder.endEncoding()
        
        return multiTexture
    }
    
}
