//
//  ViewPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-09-24.
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

final public class ViewPIX: PIXResource, PIXViewable {
    
    public typealias Model = ViewPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    #if os(iOS) || os(tvOS)
    override public var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override public var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Public Properties
    
    public var renderView: _View? {
        didSet {
            if renderView != nil {
                setNeedsBuffer()
            } else {
                viewNeedsClear()
            }
        }
    }
    
    public var renderViewContinuously = false
    public var autoSize = true
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
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
    
    // MARK: - Setup
    
    func setup() {
        applyResolution { [weak self] in
            self?.render()
        }
        PixelKit.main.render.listenToFrames { [weak self] in
            guard let self = self else { return }
            if self.renderViewContinuously {
                self.setNeedsBuffer()
            } else if self.autoSize {
                if self.renderView != nil {
                    let viewRelSize = self.renderView!.frame.size
                    let viewSize = CGSize(width: viewRelSize.width * Resolution.scale,
                                          height: viewRelSize.height * Resolution.scale)
                    let res: Resolution = .auto
                    let resSize = self.finalResolution.size
                    let resRelSize = (res / Resolution.scale).size
                    if viewSize != resSize {
                        print("----->", viewSize, resSize, resRelSize)
                        PixelKit.main.logger.log(node: self, .info, .resource, "View Res Change Detected.")
                        self.renderView!.frame = CGRect(origin: .zero, size: resRelSize)
                        self.setNeedsBuffer()
                    }
                }
            }
        }
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: Buffer
    
    public func viewNeedsRender() {
        setNeedsBuffer()
    }
    
    func setNeedsBuffer() {
        guard let view = renderView else {
            PixelKit.main.logger.log(node: self, .debug, .resource, "Nil not supported.")
            return
        }
        guard view.bounds.size.width > 0 else {
            PixelKit.main.logger.log(node: self, .debug, .resource, "View frame not set.")
            return
        }
        #if os(macOS)
        let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        // FIXME: Crash when view is not in view hierarchy (off screen)
        view.cacheDisplay(in: view.bounds, to: rep)
        let image: NSImage = NSImage(size: view.bounds.size)
        image.addRepresentation(rep)
        #else
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Resolution.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            PixelKit.main.logger.log(node: self, .error, .resource, "Image creation failed.")
            return
        }
        UIGraphicsEndImageContext()
        #endif
        guard let buffer = Texture.buffer(from: image, bits: PixelKit.main.render.bits) else {
            PixelKit.main.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        resourcePixelBuffer = buffer
        PixelKit.main.logger.log(node: self, .info, .resource, "Render View Loaded.")
        applyResolution {  [weak self] in
            self?.render()
        }
    }
    
    func viewNeedsClear() {
        resourcePixelBuffer = nil
        texture = nil
        PixelKit.main.logger.log(node: self, .info, .resource, "Clear View.")
        render()
    }
    
}
