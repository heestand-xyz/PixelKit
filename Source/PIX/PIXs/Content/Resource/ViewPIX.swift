//
//  ViewPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-09-24.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ViewPIXUI<Content: View>: View, PIXUI {
    public var node: NODE { pix }
    public let pix: PIX
    let viewPix: ViewPIX
    public var body: some View {
        NODERepView(node: pix)
    }
    public init(continuously: Bool = false, _ view: () -> (Content)) {
        let viewPix = ViewPIX()
        viewPix.renderViewContinuously = continuously
        self.viewPix = viewPix
        #if os(macOS)
        let _view: NSView = NSHostingController(rootView: view()).view
        #else
        let _view: UIView = UIHostingController(rootView: view()).view!
        #endif
        viewPix.renderView = _view
        pix = viewPix
//        PixelKit.main.render.listenToFramesUntil {
//            let resolution: Resolution = .auto(render: PixelKit.main.render)
//            guard resolution.w != 128 else { return .continue }
//            let size = (res / Resolution.scale).size.cg
//            uiView.frame = CGRect(origin: .zero, size: size)
//            viewPix.viewNeedsRender()
//            return .done
//        }
    }
}
#endif

#if os(iOS) || os(tvOS)
typealias _ViewController = UIViewController
#elseif os(macOS)
typealias _ViewController = NSViewController
#endif

public class ViewPIX: PIXResource {
    
//    class ContainerView: _View {
//        let rendereCallback: () -> ()
//        init(view: UIView, rendereCallback: @escaping () -> ()) {
//            self.rendereCallback = rendereCallback
//            super.init(frame: view.bounds)
//            addSubview(view)
//        }
//        override func setNeedsDisplay() {
//            super.setNeedsDisplay()
//            rendereCallback()
//        }
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            rendereCallback()
//        }
//        override func layoutIfNeeded() {
//            super.layoutIfNeeded()
//            rendereCallback()
//        }
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//    }
    
    #if os(iOS) || os(tvOS)
    override open var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Public Properties
    
    public var renderView: _View? {
        didSet {
            guard renderView != nil else {
                viewNeedsClear()
                return
            }
            setNeedsBuffer()
        }
    }
    
    public var renderViewContinuously = false
    
    // MARK: - Life Cycle
    
    public init() {
        super.init(name: "View", typeName: "pix-content-resource-view")
        applyResolution {
            self.setNeedsRender()
        }
        pixelKit.render.listenToFrames {
            if self.renderViewContinuously {
                self.setNeedsBuffer()
            } else {
                if self.renderView != nil {
                    let viewRelSize = self.renderView!.frame.size
                    let viewSize = LiveSize(viewRelSize) * Resolution.scale
                    let res: Resolution = .auto(render: self.pixelKit.render)
                    let resSize = self.renderResolution.size.cg
                    let resRelSize = (res / Resolution.scale).size.cg
                    if viewSize.cg != resSize {
                        self.pixelKit.logger.log(node: self, .info, .resource, "View Res Change Detected.")
                        self.renderView!.frame = CGRect(origin: .zero, size: resRelSize)
                        self.setNeedsBuffer()
                    }
                }
            }
        }
    }
    
    public func viewNeedsRender() {
        setNeedsBuffer()
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        if pixelKit.render.frame == 0 {
            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
            pixelKit.render.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let view = renderView else {
            pixelKit.logger.log(node: self, .debug, .resource, "Nil not supported.")
            return
        }
        guard view.bounds.size.width > 0 else {
            pixelKit.logger.log(node: self, .debug, .resource, "View frame not set.")
            return
        }
        #if os(macOS)
        let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        view.cacheDisplay(in: view.bounds, to: rep)
        let image: NSImage = NSImage(size: view.bounds.size)
        image.addRepresentation(rep)
        #else
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Resolution.scale.cg)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            pixelKit.logger.log(node: self, .error, .resource, "Image creation failed.")
            return
        }
        UIGraphicsEndImageContext()
        #endif
        guard let buffer = Texture.buffer(from: image, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Render View Loaded.")
        applyResolution { self.setNeedsRender() }
    }
    
    func viewNeedsClear() {
        pixelBuffer = nil
        texture = nil
        pixelKit.logger.log(node: self, .info, .resource, "Clear View.")
        setNeedsRender()
    }
    
}
