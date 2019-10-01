//
//  ViewPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-09-24.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Live
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
    public let pix: PIX
    let viewPix: ViewPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }
    public init(continuously: Bool = false, _ view: () -> (Content)) {
        let viewPix = ViewPIX()
        viewPix.renderViewContinuously = continuously
        self.viewPix = viewPix
        let uiView = UIHostingController(rootView: view()).view!
        viewPix.renderView = uiView
        pix = viewPix
//        PixelKit.main.listenToFramesUntil {
//            let res: PIX.Res = .auto
//            guard res.w != 128 else { return .continue }
//            let size = (res / PIX.Res.scale).size.cg
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
    override open var shader: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shader: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Private Properties
    
//    var containerView: ContainerView? { didSet { setNeedsBuffer() } }

    // MARK: - Public Properties
    
    public var renderView: _View? {
        didSet {
            guard renderView != nil else {
//                containerView = nil
                pixelBuffer = nil
                applyRes {
                    self.setNeedsRender()
                }
                return
            }
            setNeedsBuffer()
//            containerView = ContainerView(view: view, rendereCallback: {
//                print("<<<<<<<<<<<<<<")
//                self.setNeedsBuffer()
//            })
        }
    }
    
    public var renderViewContinuously = false
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        name = "view"
        applyRes {
            self.setNeedsRender()
        }
        pixelKit.listenToFrames {
            if self.renderViewContinuously {
                self.setNeedsBuffer()
            } else {
                if self.renderView != nil {
                    let viewRelSize = self.renderView!.frame.size
                    let viewSize = LiveSize(viewRelSize) * PIX.Res.scale
                    let res = PIX.Res.auto
                    let resSize = res.size.cg
                    let resRelSize = (res / PIX.Res.scale).size.cg
                    if viewSize.cg != resSize {
                        self.pixelKit.log(pix: self, .info, .resource, "View Res Change Detected.")
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
        if pixelKit.frame == 0 {
            pixelKit.log(pix: self, .debug, .resource, "One frame delay.")
            pixelKit.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let view = renderView else {
            pixelKit.log(pix: self, .debug, .resource, "Nil not supported.")
            return
        }
        guard view.bounds.size.width > 0 else {
            pixelKit.log(pix: self, .debug, .resource, "View frame not set.")
            return
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, PIX.Res.scale.cg)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            pixelKit.log(pix: self, .error, .resource, "Image creation failed.")
            return
        }
        UIGraphicsEndImageContext()
        guard let buffer = pixelKit.buffer(from: image) else {
            pixelKit.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.log(pix: self, .info, .resource, "Render View Loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
