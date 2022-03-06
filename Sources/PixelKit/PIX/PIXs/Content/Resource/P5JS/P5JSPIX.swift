//
//  P5JSPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2022-03-06.
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
import TextureMap

#if !os(tvOS)

final public class P5JSPIX: PIXResource, NODEResolution, PIXViewable {
    
    public typealias Model = P5JSPixelModel
    
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
    
    static let p5jsURL: URL = {
        guard let url: URL = Bundle.module.url(forResource: "p5.min", withExtension: "js") else {
            fatalError("p5.js not found")
        }
        return url
    }()
    static let baseURL: URL = {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("P5JSPIX")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
//    static let p5js: String = {
//        guard let text = try? String(contentsOf: P5JSPIX.p5jsURL) else {
//            fatalError("p5.js is corrupt")
//        }
//        return text
//    }()
    
    let helper: P5JSHelper = .init()
    
    var code: String?
    
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
        self.resolution = resolution
        super.init(model: model)
        setup()
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            code: String) {
        self.init(at: resolution)
        self.resolution = resolution
        load(code: code)
    }
    
    // MARK: - Setup
    
    func setup() {
        
        let p5jsURL: URL = Self.baseURL.appendingPathComponent("p5.min.js")
        let p5jsData: Data? = try? Data(contentsOf: Self.p5jsURL)
        try? p5jsData?.write(to: p5jsURL)
        
        setFrame()
        _resolution.didSetValue = { [weak self] in
            self?.setFrame()
            self?.applyResolution { [weak self] in
                self?.setNeedsBuffer()
            }
        }
        
        webView.navigationDelegate = helper
        helper.loaded = { [weak self] in
            self?.setNeedsBuffer()
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
    
    public func load(code: String) {
        self.code = code
        load()
    }
    
    func load() {
        guard let code = self.code else { return }
        let html: String = makeHTML(with: code)
        webView.loadHTMLString(html, baseURL: Self.baseURL)
    }
    
    // MARK: - Frame
    
    func setFrame() {
        webView.frame = CGRect(origin: .zero, size: (resolution / Resolution.scale).size)
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        webView.takeSnapshot(with: nil) { [weak self] image, error in
            guard let self = self else { return }
            guard error == nil && image != nil else {
                PixelKit.main.logger.log(node: self, .error, .resource, "P5JS image failed.", e: error)
                return
            }
            guard let buffer = Texture.buffer(from: image!, bits: PixelKit.main.render.bits) else {
                PixelKit.main.logger.log(node: self, .error, .resource, "P5JS pixel Buffer creation failed.")
                return
            }
            self.resourcePixelBuffer = buffer
            PixelKit.main.logger.log(node: self, .info, .resource, "P5JS image loaded.")
            self.applyResolution { [weak self] in
                self?.render()
            }
        }
    }
    
    func makeHTML(with code: String) -> String {
        """
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style type="text/css">
                    body {
                        margin: 0;
                    }
                </style>
            </head>
            <body>
                <script type="text/javascript" src="p5.min.js"></script>
                <script type="text/javascript">
                    function setup() {
                        createCanvas(400, 400);
                    }
                    
                    function draw() {
                        background(50);
                        circle(30, 30, 10);
                    }
                </script>
            </body>
        </html>
        """
    }
}

class P5JSHelper: NSObject, WKNavigationDelegate {
    
    var loaded: (() -> ())?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loaded?()
    }
    
}

#endif
