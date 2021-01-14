//
//  ImagePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import RenderKit

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

#if os(iOS) || os(tvOS)
public typealias _Image = UIImage
#elseif os(macOS)
public typealias _Image = NSImage
#endif

//#if canImport(SwiftUI)
//@available(iOS 13.0.0, *)
//@available(OSX 10.15, *)
//@available(tvOS 13.0.0, *)
//public struct ImagePIXUI: View, PIXUI {
//    public var node: NODE { pix }
//    public let pix: PIX
//    let imagePix: ImagePIX
//    public var body: some View {
//        NODERepView(node: pix)
//    }
//    public init(image: _Image) {
//        imagePix = ImagePIX()
//        imagePix.image = image
//        pix = imagePix
//    }
//}
//#endif

public class ImagePIX: PIXResource {

//    #if os(iOS) || os(tvOS)
//    override open var shaderName: String { return "contentResourceFlipPIX" }
//    #elseif os(macOS)
//    override open var shaderName: String { return "contentResourceBGRPIX" }
//    #endif
    override open var shaderName: String { return "contentResourceImagePIX" }
    
    // MARK: - Private Properties
    
    var flip: Bool {
        #if os(iOS) || os(tvOS)
        return true
        #elseif os(macOS)
        return false
        #endif
    }
    
    var swizzel: Bool {
        return false
    }
    
    // MARK: - Public Properties
    
    public var image: _Image? { didSet { setNeedsBuffer() } }
    
    #if !os(macOS)
    public var resizeToFitResolution: Resolution? = nil
    #endif
    
    var resizedResolution: Resolution? {
        #if !os(macOS)
        guard let res = resizeToFitResolution else { return nil }
        guard let image = image else { return nil }
        return Resolution.size(image.size).aspectResolution(to: .fit, in: res)
        #else
        return nil
        #endif
    }
    
    public var tint: Bool = false
    public var tintColor: PixelColor = .white
    public var bgColor: PixelColor = .clear

    // MARK: - Property Helpers
    
    public override var values: [Floatable] {
        [tint, tintColor, bgColor, flip, swizzel]
    }
    
    // MARK: - Life Cycle
    
    public init() {
        super.init(name: "Image", typeName: "pix-content-resource-image")
        self.applyResolution {
            self.setNeedsRender()
        }
        pixelKit.render.listenToFramesUntil {
            if self.realResolution != nil {
                return .done
            }
            if self.renderResolution != ._128 {
                self.applyResolution {
                    self.setNeedsRender()
                }
                return .done
            }
            return .continue
        }
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard var image = image else {
            pixelKit.logger.log(node: self, .debug, .resource, "Setting Image to Nil")
            clearRender()
            return
        }
        #if !os(macOS)
        if let res = resizedResolution {
            image = Texture.resize(image, to: res.size)
        }
        #endif
        if pixelKit.render.frame == 0 && frameLoopRenderThread == .main {
            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
            pixelKit.render.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        let bits: Bits = pixelKit.render.bits
        guard let buffer = Texture.buffer(from: image, bits: bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.", loop: true)
            return
        }
        pixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.", loop: true)
        applyResolution { self.setNeedsRender() }
    }
    
}
