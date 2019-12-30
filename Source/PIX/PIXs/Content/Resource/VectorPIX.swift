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
import WebKit

public class VectorPIX: PIXResource {
    
//    #if os(iOS) || os(tvOS)
//    override open var shaderName: String { return "contentResourceFlipPIX" }
//    #elseif os(macOS)
//    override open var shaderName: String { return "contentResourceBGRPIX" }
//    #endif
    override open var shaderName: String { return "nilPIX" }
    
    public var resolution: Resolution { didSet { setNeedsBuffer() } }
    
    let helper: VectorHelper
    
    let webView: WKWebView
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        helper = VectorHelper()
        webView = WKWebView()
        self.resolution = resolution
        super.init()
        webView.navigationDelegate = helper
        helper.loaded = setNeedsBuffer
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
        guard let svg: String = try? String(contentsOf: url) else {
            pixelKit.logger.log(.error, .resource, "Vector SVG file corrupted.")
            return
        }
        webView.loadHTMLString(svg, baseURL: nil)
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
//        if pixelKit.render.frame == 0 {
//            pixelKit.logger.log(node: self, .debug, .resource, "Vector one frame delay.")
//            pixelKit.render.delay(frames: 1, done: {
//                self.setNeedsBuffer()
//            })
//            return
//        }
//        UIGraphicsBeginImageContextWithOptions(resolution.size.cg, false, 0)
//        defer { UIGraphicsEndImageContext() }
//        guard let context = UIGraphicsGetCurrentContext() else {
//            pixelKit.logger.log(.error, .resource, "Vector context fail.")
//            return
//        }
//        webView.layer.render(in: context)
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            pixelKit.logger.log(node: self, .error, .resource, "Vector image fail.")
//            return
//        }
        webView.takeSnapshot(with: nil) { image, error in
            guard error == nil && image != nil else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Vector image failed.", e: error)
                return
            }
            guard let buffer = Texture.buffer(from: image!, bits: self.pixelKit.render.bits) else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Vector pixel Buffer creation failed.")
                return
            }
            self.pixelBuffer = buffer
            self.pixelKit.logger.log(node: self, .info, .resource, "Vector image loaded.")
            self.applyResolution { self.setNeedsRender() }
        }
    }
    
}

class VectorHelper: NSObject, WKNavigationDelegate {
    
    var loaded: (() -> ())?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loaded?()
    }
    
}
