//
//  VectorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-06-02.
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
import PixelColor

#if !os(tvOS)

final public class VectorPIX: PIXResource, NODEResolution, PIXViewable {
    
    public typealias Model = VectorPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    #if os(iOS)
    override public var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override public var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    let helper: VectorHelper = .init()
    
    public var scale: CGFloat {
        get { model.scale }
        set {
            model.scale = newValue
            load()
        }
    }
    
    public var position: CGPoint {
        get { model.position }
        set {
            model.position = newValue
            load()
        }
    }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    public var backgroundColor: PixelColor {
        get { model.backgroundColor }
        set {
            model.backgroundColor = newValue
            load()
        }
    }
    
    var svg: String?
    
    let webView: WKWebView = .init()
    
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
                            named name: String) {
        self.init(at: resolution)
        load(named: name)
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            url: URL) {
        self.init(at: resolution)
        load(url: url)
    }
    
    // MARK: - Setup
    
    func setup() {
        webView.navigationDelegate = helper
        helper.loaded = { [weak self] in
            self?.setNeedsBuffer()
        }
        setFrame()
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
    
    public func load(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "svg") else {
            PixelKit.main.logger.log(.error, .resource, "Vector SVG file not found.")
            return
        }
        load(url: url)
    }
    
    public func load(url: URL) {
        guard let svg: String = try? String(contentsOf: url) else {
            PixelKit.main.logger.log(.error, .resource, "Vector SVG file corrupted.")
            return
        }
        self.svg = svg
        load()
    }
    
    func load() {
        guard let svg = self.svg else { return }
        let html = makeHTML(with: svg)
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.google.com/")!)
    }
    
    // MARK: - Frame
    
    func setFrame() {
        webView.frame = CGRect(origin: .zero, size: (resolution / Resolution.scale).size)
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
//        if PixelKit.main.render.frame == 0 {
//            PixelKit.main.logger.log(node: self, .debug, .resource, "Vector one frame delay.")
//            PixelKit.main.render.delay(frames: 1, done: {
//                self.setNeedsBuffer()
//            })
//            return
//        }
//        UIGraphicsBeginImageContextWithOptions(resolution.size, false, 0)
//        defer { UIGraphicsEndImageContext() }
//        guard let context = UIGraphicsGetCurrentContext() else {
//            PixelKit.main.logger.log(.error, .resource, "Vector context fail.")
//            return
//        }
//        webView.layer.render(in: context)
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            PixelKit.main.logger.log(node: self, .error, .resource, "Vector image fail.")
//            return
//        }
        webView.takeSnapshot(with: nil) { [weak self] image, error in
            guard let self = self else { return }
            guard error == nil && image != nil else {
                PixelKit.main.logger.log(node: self, .error, .resource, "Vector image failed.", e: error)
                return
            }
            guard let buffer = Texture.buffer(from: image!, bits: PixelKit.main.render.bits) else {
                PixelKit.main.logger.log(node: self, .error, .resource, "Vector pixel Buffer creation failed.")
                return
            }
            self.resourcePixelBuffer = buffer
            PixelKit.main.logger.log(node: self, .info, .resource, "Vector image loaded.")
            self.applyResolution { [weak self] in
                self?.render()
            }
        }
    }
    
    func makeHTML(with svg: String) -> String {
        let size: CGSize = (resolution / Resolution.scale).size
        let bgColorHex: String = backgroundColor.hex
        var svg_html: String = svg
        let svg_html_components = svg_html.components(separatedBy: "<svg")
        let svg_html_splits = svg_html_components.last!.split(separator: ">", maxSplits: 1)
        let svg_html_style_components = svg_html_splits.first!.components(separatedBy: "style=\"")
        if svg_html_style_components.count == 2 {
            svg_html = svg_html_components.first! + "<svg" + svg_html_style_components.first! + "style=\"width: 100%; height: 100%;" + svg_html_style_components.last! + ">" + svg_html_splits.last!
        } else {
            svg_html = svg_html_components.first! + "<svg" + svg_html_splits.first! + " style=\"width: 100%; height: 100%;\">" + svg_html_splits.last!
        }
        return """
        <html>
        <head><title>Pixel Nodes - Vector</title></head>
        <body style="margin: 0; background-color: \(bgColorHex);">
            <div style="position: absolute; left: calc(50% + \(position.x * size.width)px); top: calc(50% + \(-position.y * size.height)px); transform: translate(-50%, -50%); width: \(size.width * scale)px; height: \(size.height * scale)px;">
                \(svg_html)
            </div>
        </body>
        </html>
        """
    }
    
}

class VectorHelper: NSObject, WKNavigationDelegate {
    
    var loaded: (() -> ())?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loaded?()
    }
    
}

#endif
