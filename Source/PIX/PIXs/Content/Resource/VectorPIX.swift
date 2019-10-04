//
//  VectorPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-06-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import RenderKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftSVG

public class VectorPIX: PIXResource {
    
    #if os(iOS) || os(tvOS)
    override open var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    public var resolution: Resolution { didSet { setNeedsBuffer(); applyResolution { self.setNeedsRender() } } }
    
    var svgLayer: CALayer? { didSet { setNeedsBuffer() } }
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution) {
        self.resolution = resolution
        super.init()
        name = "vector"
    }
    
    // MARK: - Load
    
    public func load(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "svg") else {
            pixelKit.logger.log(.error, .resource, "Vector SVG file not found.")
            return
        }
        load(url: url)
    }
    
    public func load(url: URL) {
        CALayer(SVGURL: url) { layer in
            self.svgLayer = layer
        }
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let svgLayer = svgLayer else {
            pixelKit.logger.log(.error, .resource, "Vector not loaded.")
            return
        }
        UIGraphicsBeginImageContextWithOptions(resolution.size.cg, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            pixelKit.logger.log(.error, .resource, "Vector context fail.")
            return
        }
        svgLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            pixelKit.logger.log(node: self, .error, .resource, "Vector image fail.")
            return
        }
        if pixelKit.render.frame == 0 {
            pixelKit.logger.log(node: self, .debug, .resource, "Vector one frame delay.")
            pixelKit.render.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = Texture.buffer(from: image, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Vector pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Vector image loaded.")
        applyResolution { self.setNeedsRender() }
    }
    
}
