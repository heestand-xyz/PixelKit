//
//  ImagePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public class ImagePIX: PIXResource {
    
    override open var shader: String { return "contentResourceImagePIX" }
    
    // MARK: - Public Properties
    
    #if os(iOS)
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    #elseif os(macOS)
    public var image: NSImage? { didSet { setNeedsBuffer() } }
    #endif
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws { self.init() }
//    override public func encode(to encoder: Encoder) throws {}
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            pixels.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if pixels.frame == 0 {
            pixels.log(pix: self, .debug, .resource, "One frame delay.")
            pixels.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = pixels.buffer(from: image) else {
            pixels.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixels.log(pix: self, .info, .resource, "Image Loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
