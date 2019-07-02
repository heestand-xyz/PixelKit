//
//  VectorPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-06-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftSVG

public class VectorPIX: PIXResource {
    
    #if os(iOS)
    override open var shader: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shader: String { return "contentResourceBGRPIX" }
    #endif
    
    public var res: Res { didSet { setNeedsBuffer(); applyRes { self.setNeedsRender() } } }
    
    var svgLayer: CALayer? { didSet { setNeedsBuffer() } }
    
    // MARK: - Life Cycle
    
    public init(res: Res) {
        self.res = res
        super.init()
        name = "vector"
    }
    
    // MARK: - Load
    
    public func load(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "svg") else {
            pixelKit.log(.error, .resource, "Vector SVG file not found.")
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
            pixelKit.log(.error, .resource, "Vector not loaded.")
            return
        }
        UIGraphicsBeginImageContextWithOptions(res.size.cg, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            pixelKit.log(.error, .resource, "Vector context fail.")
            return
        }
        svgLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            pixelKit.log(pix: self, .error, .resource, "Vector image fail.")
            return
        }
        if pixelKit.frame == 0 {
            pixelKit.log(pix: self, .debug, .resource, "Vector one frame delay.")
            pixelKit.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = pixelKit.buffer(from: image) else {
            pixelKit.log(pix: self, .error, .resource, "Vector pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.log(pix: self, .info, .resource, "Vector image loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
