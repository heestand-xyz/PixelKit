//
//  ImagePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ImagePIX: PIXContent, PIXable {
    
    var kind: HxPxE.PIXKind = .image
    
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    
    public init() {
        super.init(res: .unknown, resource: true)
    }
    
    func setNeedsBuffer() {
        guard let contentImage = image else {
            print("HxPxE: ImagePIX: Nil not supported yet.")
            return
        }
        let width = contentImage.size.width * contentImage.scale
        let height = contentImage.size.height * contentImage.scale
        res = .custom(res: CGSize(width: width, height: height))
        contentPixelBuffer = buffer(from: contentImage)
        setNeedsRender()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    override public func encode(to encoder: Encoder) throws {}
    
    // MARK: Buffer
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue, String(kCVPixelBufferIOSurfacePropertiesKey): [
            "IOSurfaceOpenGLESFBOCompatibility": true,
            "IOSurfaceOpenGLESTextureCompatibility": true,
            "IOSurfaceCoreAnimationCompatibility": true,
            ]] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(width), Int(height), kCVPixelFormatType_32BGRA/*ARGB*/, attrs, &pixelBuffer)
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
