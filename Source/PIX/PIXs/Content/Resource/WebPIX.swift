//
//  WebPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-07-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import WebKit

public class WebPIX: PIXResource, PIXRes {
    
    override open var shader: String { return "contentResourceBGRPIX" }
    
    // MARK: - Private Properties
    
    let helper: WebHelper
    
    // MARK: - Public Properties
    
    public var res: Res { didSet { /*setFrame();*/ applyRes { self.setNeedsBuffer() } } }
    
    public var url: URL = URL(string: "http://pixelkit.net/")! { didSet { refresh() } }
    public var webView: WKWebView
    
    // MARK: - Life Cycle
    
    public required init(res: PIX.Res) {
        
        self.res = res
        
        helper = WebHelper()
        
        webView = WKWebView()
        
        super.init()
        
        name = "web"
        
        webView.navigationDelegate = helper
        helper.refreshCallback = {
            self.pixelKit.log(pix: self, .info, .resource, "Web refreshed!")
            self.setNeedsBuffer()
        }
        
        refresh()
        
//        setFrame()
        
        applyRes { self.setNeedsRender() }
        
    }
    
//    func setFrame() {
//        webView.frame = CGRect(origin: .zero, size: res.size.cg)
//    }
    
    // MARK: - Load
    
    public func refresh() {
        pixelKit.log(pix: self, .info, .resource, "Web refresh: \(url)")
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Buffer
    
    func setNeedsBuffer() {
        let config = WKSnapshotConfiguration()
        if #available(OSX 10.15, *) {
            if #available(iOS 13.0, *) {
                config.afterScreenUpdates = false
            }
        }
        config.rect = CGRect(origin: .zero, size: res.size.cg)
        webView.takeSnapshot(with: config) { image, error in
            guard error == nil else {
                self.pixelKit.log(pix: self, .error, .resource, "Web snapshot failed.", e: error)
                return
            }
            guard let image = image else {
                self.pixelKit.log(pix: self, .error, .resource, "Web snapshot image not avalible.")
                return
            }
            guard let buffer = self.pixelKit.buffer(from: image) else {
                self.pixelKit.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
                return
            }
            self.pixelBuffer = buffer
            self.pixelKit.log(pix: self, .info, .resource, "Image Loaded.")
            self.setNeedsRender()
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
