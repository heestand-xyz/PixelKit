//
//  PaintPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2020-02-02.
//  Copyright © 2020 Hexagons. All rights reserved.
//

import RenderKit
import LiveValues
import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import PencilKit

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
public struct PaintPIXUI: View, PIXUI {
    public var node: NODE { pix }
    public let pix: PIX
    let paintPix: PaintPIX
    public var body: some View {
        NODERepView(node: pix)
    }
    public init() {
        paintPix = PaintPIX()
        pix = paintPix
    }
}
#endif

@available(iOS 13.0, *)
public class PaintPIX: PIXResource {
    
    override open var shaderName: String { return "contentResourcePIX" }
//    #if os(iOS) || os(tvOS)
//    override open var shaderName: String { return "contentResourceFlipPIX" }
//    #elseif os(macOS)
//    override open var shaderName: String { return "contentResourceBGRPIX" }
//    #endif

    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { setFrame(); applyResolution { self.setNeedsBuffer() } } }

    public let canvasView: PKCanvasView
    public var drawing: PKDrawing {
        get { canvasView.drawing }
        set { canvasView.drawing = newValue }
    }
    
//    public enum Tool: String, CaseIterable {
//        var tool: PKTool {
//            switch self {
//
//            }
//        }
//    }
//    public var tool: Tool
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        canvasView = PKCanvasView()
        super.init()
        name = "paint"
        setFrame()
    }
    
    func setFrame() {
        canvasView.frame = CGRect(origin: .zero, size: resolution.size.cg)
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        let frame: CGRect = CGRect(origin: .zero, size: resolution.size.cg)
        let image: UIImage = drawing.image(from: frame, scale: 1.0)
        if pixelKit.render.frame == 0 {
            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
            pixelKit.render.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let cgImage: CGImage = image.cgImage else { return }
        guard let bits = LiveColor.Bits(rawValue: cgImage.bitsPerPixel) else { return }
        guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.")
        applyResolution { self.setNeedsRender() }
    }
    
}
