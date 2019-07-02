//
//  ImagePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public class ImagePIX: PIXResource {
    
    #if os(iOS)
    override open var shader: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shader: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Public Properties
    
    #if os(iOS)
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    #elseif os(macOS)
    public var image: NSImage? { didSet { setNeedsBuffer() } }
    #endif
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        name = "image"
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            pixelKit.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if pixelKit.frame == 0 {
            pixelKit.log(pix: self, .debug, .resource, "One frame delay.")
            pixelKit.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = pixelKit.buffer(from: image) else {
            pixelKit.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.log(pix: self, .info, .resource, "Image Loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
