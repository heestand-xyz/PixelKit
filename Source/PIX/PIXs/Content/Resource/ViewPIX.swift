//
//  ViewPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-09-24.
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

final public class ViewPIX: PIXResource, PIXViewable, ObservableObject {
    
    #if os(iOS) || os(tvOS)
    override public var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override public var shaderName: String { return "contentResourceBGRPIX" }
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
    
    public required init() {
        super.init(name: "View", typeName: "pix-content-resource-view")
        applyResolution {
            self.render()
        }
        pixelKit.render.listenToFrames {
            if self.renderViewContinuously {
                self.setNeedsBuffer()
            } else {
                if self.renderView != nil {
                    let viewRelSize = self.renderView!.frame.size
                    let viewSize = CGSize(width: viewRelSize.width * Resolution.scale,
                                          height: viewRelSize.height * Resolution.scale)
                    let res: Resolution = .auto(render: self.pixelKit.render)
                    let resSize = self.finalResolution.size
                    let resRelSize = (res / Resolution.scale).size
                    if viewSize != resSize {
                        self.pixelKit.logger.log(node: self, .info, .resource, "View Res Change Detected.")
                        self.renderView!.frame = CGRect(origin: .zero, size: resRelSize)
                        self.setNeedsBuffer()
                    }
                }
            }
        }
    }
    
    public convenience init(view: _View) {
        self.init()
        renderView = view
        setNeedsBuffer()
    }
    
    public convenience init<Content: View>(content: () -> (Content)) {
        self.init()
        #if os(macOS)
        renderView = NSHostingController(rootView: content()).view
        #else
        renderView = UIHostingController(rootView: content()).view
        #endif
        setNeedsBuffer()
    }
    
    public func viewNeedsRender() {
        setNeedsBuffer()
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
//        if pixelKit.render.frame == 0 {
//            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
//            pixelKit.render.delay(frames: 1, done: {
//                self.setNeedsBuffer()
//            })
//            return
//        }
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
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Resolution.scale)
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
        resourcePixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Render View Loaded.")
        applyResolution { self.render() }
    }
    
    func viewNeedsClear() {
        resourcePixelBuffer = nil
        texture = nil
        pixelKit.logger.log(node: self, .info, .resource, "Clear View.")
        render()
    }
    
}
