//
//  PixelKitTexture.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

#if os(iOS)
import MetalPerformanceShadersProxy
#elseif os(macOS)
import MetalKit
#endif
import VideoToolbox

extension PixelKit {
    
    enum TextureError: Error {
        case pixelBuffer(Int)
        case emptyFail
        case copy(String)
        case multi(String)
        case mipmap
    }
    
    func buffer(from image: CGImage, at size: CGSize?) -> CVPixelBuffer? {
        #if os(iOS)
        return buffer(from: UIImage(cgImage: image))
        #elseif os(macOS)
        guard size != nil else { return nil }
        return buffer(from: NSImage(cgImage: image, size: size!))
        #endif
    }
    
    #if os(iOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    func buffer(from image: _Image) -> CVPixelBuffer? {
        
        #if os(iOS)
        let scale: CGFloat = image.scale
        #elseif os(macOS)
        let scale: CGFloat = 1.0
        #endif
        
        let width = image.size.width * scale
        let height = image.size.height * scale
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
//            String(kCVPixelBufferIOSurfacePropertiesKey): [
//                "IOSurfaceOpenGLESFBOCompatibility": true,
//                "IOSurfaceOpenGLESTextureCompatibility": true,
//                "IOSurfaceCoreAnimationCompatibility": true,
//                ]
            ] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         bits.os,
                                         attrs,
                                         &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8, // FIXME: bits.rawValue,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return nil
        }
        
        #if os(iOS)
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        #elseif os(macOS)
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        #endif
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func makeTexture(from pixelBuffer: CVPixelBuffer, with commandBuffer: MTLCommandBuffer, force8bit: Bool = false) throws -> MTLTexture {
//        let width = CVPixelBufferGetWidth(pixelBuffer)
//        let height = CVPixelBufferGetHeight(pixelBuffer)
//        var cvTextureOut: CVMetalTexture?
//        let colorBits: MTLPixelFormat = force8bit ? LiveColor.Bits._8.mtl : bits.mtl
//        let attributes = [
////            "IOSurfaceOpenGLESFBOCompatibility": true,
////            "IOSurfaceOpenGLESTextureCompatibility": true,
//            "IOSurfaceCoreAnimationCompatibility": true
//            ] as CFDictionary
//        let kCVReturn = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, attributes, colorBits, width, height, 0, &cvTextureOut)
//        guard kCVReturn == kCVReturnSuccess else {
//            throw TextureError.pixelBuffer(-1)
//        }
//        guard let cvTexture = cvTextureOut else {
//            throw TextureError.pixelBuffer(-2)
//        }
//        guard let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
//            throw TextureError.pixelBuffer(-3)
//        }
//        return inputTexture
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        guard let image = cgImage else {
            throw TextureError.pixelBuffer(-4)
        }
        return try makeTexture(from: image, with: commandBuffer)
    }

    func makeTexture(from image: CGImage, with commandBuffer: MTLCommandBuffer) throws -> MTLTexture {
        #if !targetEnvironment(simulator)
        let textureLoader = MTKTextureLoader(device: metalDevice)
        let texture: MTLTexture = try textureLoader.newTexture(cgImage: image, options: nil)
        try mipmap(texture: texture, with: commandBuffer)
        return texture
        #else
        return try emptyTexture(size: CGSize(width: 1, height: 1))
        #endif
    }
    
    func mipmap(texture: MTLTexture, with commandBuffer: MTLCommandBuffer) throws {
        guard texture.mipmapLevelCount > 1 else { return }
        guard let commandEncoder: MTLBlitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.mipmap
        }
        commandEncoder.generateMipmaps(for: texture)
        commandEncoder.endEncoding()
    }
    
    func emptyTexture(size: CGSize) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: bits.mtl, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let texture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.emptyFail
        }
        return texture
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
//        blitEncoder.generateMipmaps(for: textureCopy)
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    func makeMultiTexture(from textures: [MTLTexture], with commandBuffer: MTLCommandBuffer, in3D: Bool = false) throws -> MTLTexture {
        
        guard !textures.isEmpty else {
            throw TextureError.multi("Passed Textures array is empty.")
        }
        
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = bits.mtl
        descriptor.textureType = in3D ? .type3D : .type2DArray
        descriptor.width = textures.first!.width
        descriptor.height = textures.first!.height
        descriptor.mipmapLevelCount = textures.first?.mipmapLevelCount ?? 1
        if in3D {
            descriptor.depth = textures.count
        } else {
            descriptor.arrayLength = textures.count
        }
        
        guard let multiTexture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.multi("Texture creation failed.")
        }

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.multi("Blit Encoder creation failed.")
        }
        
        for (i, texture) in textures.enumerated() {
            for j in 0..<texture.mipmapLevelCount {
                let width = Int(CGFloat(texture.width) / pow(2, CGFloat(j)))
                let height = Int(CGFloat(texture.height) / pow(2, CGFloat(j)))
                blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: j, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: width, height: height, depth: 1), to: multiTexture, destinationSlice: in3D ? 0 : i, destinationLevel: j, destinationOrigin: MTLOrigin(x: 0, y: 0, z: in3D ? i : 0))
            }
        }
        blitEncoder.endEncoding()
        
        return multiTexture
    }
    
    func textures(from pix: PIX, with commandBuffer: MTLCommandBuffer) throws -> (a: MTLTexture?, b: MTLTexture?, custom: MTLTexture?) {

        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else {
                    throw RenderError.texture("Pixel Buffer is nil.")
                }
                inputTexture = try makeTexture(from: pixelBuffer, with: commandBuffer, force8bit: (pix as? CameraPIX) != nil)
            } else if pixContent is PIXGenerator {
                generator = true
            } else if let pixSprite = pixContent as? PIXSprite {
                guard let spriteTexture = pixSprite.sceneView.texture(from: pixSprite.scene) else {
                    throw RenderError.texture("Sprite Texture fail.")
                }
                let spriteImage: CGImage = spriteTexture.cgImage()
                guard let spriteBuffer = buffer(from: spriteImage, at: pixSprite.res.size.cg) else {
                    throw RenderError.texture("Sprite Buffer fail.")
                }
                inputTexture = try makeTexture(from: spriteBuffer, with: commandBuffer)
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            if let pixInMulti = pixIn as? PIXInMulti {
                var inTextures: [MTLTexture] = []
                for (i, pixOut) in pixInMulti.inPixs.enumerated() {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture \(i) not found for: \(pixOut)")
                    }
                    try mipmap(texture: pixOutTexture, with: commandBuffer)
                    inTextures.append(pixOutTexture)
                }
                inputTexture = try makeMultiTexture(from: inTextures, with: commandBuffer)
            } else {
                guard let pixOut = pixIn.pixInList.first else {
                    throw RenderError.texture("inPix not connected.")
                }
                var feed = false
                if let feedbackPix = pixIn as? FeedbackPIX {
                    if feedbackPix.readyToFeed && feedbackPix.feedActive {
                        guard let feedTexture = feedbackPix.feedTexture else {
                            throw RenderError.texture("Feed Texture not avalible.")
                        }
                        inputTexture = feedTexture
                        feed = true
                    }
                }
                if !feed {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture not found for: \(pixOut)")
                    }
                    inputTexture = pixOutTexture // CHECK copy?
                    if pix is PIXInMerger {
                        let pixOutB = pixIn.pixInList[1]
                        guard let pixOutTextureB = pixOutB.texture else {
                            throw RenderError.texture("IO Texture B not found for: \(pixOutB)")
                        }
                        secondInputTexture = pixOutTextureB // CHECK copy?
                    }
                }
            }
        }
        
        guard generator || inputTexture != nil else {
            throw RenderError.texture("Input Texture missing.")
        }
        
        // Mipmap
        
        if inputTexture != nil {
            try mipmap(texture: inputTexture!, with: commandBuffer)
        }
        if secondInputTexture != nil {
            try mipmap(texture: secondInputTexture!, with: commandBuffer)
        }
        
        // MARK: Custom Render
        
        var customTexture: MTLTexture?
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                throw RenderError.custom("PixelCustomRenderDelegate not implemented.")
            }
            if let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) {
                inputTexture = nil
                customTexture = customRenderedTexture
            }
        }
        
        if pix is PIXInMerger {
            if !generator && pix.customMergerRenderActive {
                guard let customMergerRenderDelegate = pix.customMergerRenderDelegate else {
                    throw RenderError.custom("PixelCustomMergerRenderDelegate not implemented.")
                }
                let customRenderedTextures = customMergerRenderDelegate.customRender(a: inputTexture!, b: secondInputTexture!, with: commandBuffer)
                if let customRenderedTexture = customRenderedTextures {                
                    inputTexture = nil
                    secondInputTexture = nil
                    customTexture = customRenderedTexture
                }
            }
        }
        
        if let timeMachinePix = pix as? TimeMachinePIX {
            let textures = timeMachinePix.customRender(inputTexture!, with: commandBuffer)
            inputTexture = try makeMultiTexture(from: textures, with: commandBuffer, in3D: true)
        }
        
        return (inputTexture, secondInputTexture, customTexture)
        
    }
    
}
