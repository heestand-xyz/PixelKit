//
//  WebPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-07-03.
//

import RenderKit
import Resolution
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if !os(tvOS)
import WebKit
#endif

#if !os(tvOS)

@available(OSX 10.13, *)
@available(iOS 11, *)
final public class WebPIX: PIXResource, NODEResolution, PIXViewable {
    
    public typealias Model = WebPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    #if os(iOS) || os(tvOS)
    override public var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override public var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Private Properties
    
    let helper: WebHelper = .init()
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    public var url: URL {
        get { model.url }
        set {
            model.url = newValue
            refresh()
        }
    }
    public var webView: WKWebView = .init()
    
    public override var liveList: [LiveWrap] {
        [_resolution] + super.liveList
    }
    
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
    
    public init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
        setup()
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            url: URL) {
        self.init(at: resolution)
        self.url = url
        self.refresh()
    }
    
    // MARK: - Setup
    
    func setup() {
        
        webView.navigationDelegate = helper
        helper.refreshCallback = { [weak self] in
            self?.pixelKit.logger.log(node: self, .info, .resource, "Web refreshed!")
            self?.setNeedsBuffer()
        }
        
        refresh()
        
        setFrame()
        
        applyResolution { [weak self] in
            self?.renderWeb()
        }
        
        _resolution.didSetValue = { [weak self] in
            self?.setFrame()
            self?.applyResolution { [weak self] in
                self?.setNeedsBuffer()
            }
        }
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Load
    
    public func refresh() {
        pixelKit.logger.log(node: self, .info, .resource, "Web refresh: \(url)")
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    public func renderWeb() {
        setNeedsBuffer()
    }
    
    // MARK: - Frame
    
    func setFrame() {
        webView.frame = CGRect(origin: .zero, size: (resolution / Resolution.scale).size)
    }
    
    // MARK: - Buffer
    
    func setNeedsBuffer() {
//        let config = WKSnapshotConfiguration()
//        if #available(OSX 10.15, *) {
//            if #available(iOS 13.0, *) {
//                // CHECK
////                config.afterScreenUpdates = false
//            }
//        }
//        config.rect = CGRect(origin: .zero, size: resolution.size)
        webView.takeSnapshot(with: nil) { [weak self] image, error in
            guard let self = self else { return }
            guard error == nil else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Web snapshot failed.", e: error)
                return
            }
            guard let image = image else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Web snapshot image not available.")
                return
            }
            guard let buffer = Texture.buffer(from: image, bits: self.pixelKit.render.bits) else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
                return
            }
            self.resourcePixelBuffer = buffer
            self.pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.")
            self.render()
        }
    }
    
}

// MARK: - Web Helper

class WebHelper: NSObject, WKNavigationDelegate {

    var refreshCallback: (() -> ())?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshCallback?()
    }

}

#endif
