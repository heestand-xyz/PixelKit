//
//  ImagePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import RenderKit
import Resolution

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
import PixelColor

#if os(iOS) || os(tvOS)
public typealias UINSImage = UIImage
#elseif os(macOS)
public typealias UINSImage = NSImage
#endif

final public class ImagePIX: PIXResource, PIXViewable {

//    #if os(iOS) || os(tvOS)
//    override open var shaderName: String { return "contentResourceFlipPIX" }
//    #elseif os(macOS)
//    override open var shaderName: String { return "contentResourceBGRPIX" }
//    #endif
    override public var shaderName: String { return "contentResourceImagePIX" }
    
    // MARK: - Private Properties
    
    var flip: Bool {
        #if os(iOS) || os(tvOS)
        return true
        #elseif os(macOS)
        return false
        #endif
    }
    
    var swizzel: Bool {
        false //PixelKit.main.render.bits == ._16
    }
    
    // MARK: - Public Properties
    
    public var image: UINSImage? { didSet { setNeedsBuffer() } }
    
    @Published public var imageLoaded: Bool = false
    
    /// Set `resizeResolution` to update image.
    public var resizePlacement: Texture.ImagePlacement = .fit
    public var resizeResolution: Resolution? = nil {
        didSet {
            guard resizeResolution != oldValue else { return }
            setNeedsBuffer()
        }
    }
    var resizedResolution: Resolution?
    
    public var tint: Bool = false
    public var tintColor: PixelColor = .white
    public var bgColor: PixelColor = .clear

    // MARK: - Property Helpers
    
    public override var values: [Floatable] {
        [tint, tintColor, bgColor, flip, swizzel]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Image", typeName: "pix-content-resource-image")
//        self.applyResolution {
//            self.render()
//        }
//        pixelKit.render.listenToFramesUntil {
//            if self.derivedResolution != nil {
//                return .done
//            }
//            if self.derivedResolution != ._128 {
//                self.applyResolution {
//                    self.render()
//                }
//                return .done
//            }
//            return .continue
//        }
    }
    
    #if os(macOS)
    public convenience init(image: NSImage) {
        self.init()
        self.image = image
        setNeedsBuffer()
    }
    #else
    public convenience init(image: UIImage) {
        self.init()
        self.image = image
        setNeedsBuffer()
    }
    #endif
    public convenience init(named name: String) {
        self.init()
        self.image = UINSImage(named: name)
        setNeedsBuffer()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard var image = image else {
            pixelKit.logger.log(node: self, .debug, .resource, "Setting Image to Nil")
            clearRender()
            imageLoaded = false
            return
        }
        if let res = resizeResolution {
            image = Texture.resize(image, to: res.size, placement: resizePlacement)
            resizedResolution = image.resolution
        }
//        if pixelKit.render.frame == 0 && frameLoopRenderThread == .main {
//            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
//            pixelKit.render.delay(frames: 1, done: {
//                self.setNeedsBuffer()
//            })
//            return
//        }
        let bits: Bits = pixelKit.render.bits
//        if bits == ._16 {
//            do {
//                let texture: MTLTexture = try Texture.loadTexture(from: image, device: PixelKit.main.render.metalDevice)
//                resourceTexture = texture
//            } catch {
//                pixelKit.logger.log(node: self, .error, .resource, "Float16 requres iOS 14 or macOS 11.", loop: true, e: error)
//            }
//        } else {
            guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: bits) else {
                pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.", loop: true)
                return
            }
            resourcePixelBuffer = buffer
//        }
        pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.")
        applyResolution { [weak self] in
            self?.imageLoaded = true
            self?.render()
            PixelKit.main.render.delay(frames: 10, done: { [weak self] in
                self?.render()
            })
        }
    }
    
}
