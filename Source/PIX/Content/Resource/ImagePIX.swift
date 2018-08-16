//
//  ImagePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ImagePIX: PIXResource, PIXofaKind {
    
    var kind: PIX.Kind = .image
    
    override var shader: String { return "imagePIX" }
    
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    
    public init(named: String? = nil) {
        if named != nil { image = UIImage(named: named!) }
        super.init()
        if image != nil { self.setNeedsBuffer() }
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    override public func encode(to encoder: Encoder) throws {}
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            Logger.main.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if HxPxE.main.frameIndex == 0 {
            Logger.main.log(pix: self, .debug, .resource, "One frame delay.")
            HxPxE.main.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = buffer(from: image) else {
            Logger.main.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        Logger.main.log(pix: self, .info, .resource, "Image Loaded.")
        setNeedsRender()
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue, String(kCVPixelBufferIOSurfacePropertiesKey): [
            "IOSurfaceOpenGLESFBOCompatibility": true,
            "IOSurfaceOpenGLESTextureCompatibility": true,
            "IOSurfaceCoreAnimationCompatibility": true,
            ]] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(width), Int(height), HxPxE.main.colorBits.os, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}
