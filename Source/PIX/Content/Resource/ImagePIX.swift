//
//  ImagePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class ImagePIX: PIXResource, PIXofaKind {
    
    var kind: PIX.Kind = .image
    
    override var shader: String { return "contentResourceImagePIX" }
    
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    override public func encode(to encoder: Encoder) throws {}
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            pixels.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if pixels.frameIndex == 0 {
            pixels.log(pix: self, .debug, .resource, "One frame delay.")
            pixels.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = buffer(from: image) else {
            pixels.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixels.log(pix: self, .info, .resource, "Image Loaded.")
        applyRes { self.setNeedsRender() }
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
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(width), Int(height), pixels.colorBits.os, attrs, &pixelBuffer)
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
