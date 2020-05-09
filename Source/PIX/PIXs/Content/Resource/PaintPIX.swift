//
//  PaintPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2020-02-02.
//  Copyright © 2020 Hexagons. All rights reserved.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

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
    
    override open var shaderName: String { return "contentResourceBackgroundPIX" }

    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { setFrame(); applyResolution { self.setNeedsBuffer() } } }
    
    let helper: PaintHelper

    public let canvasView: PKCanvasView
    public var showTools: Bool = false {
        didSet {
            guard let window: UIWindow = UIApplication.shared.keyWindow else { return }
            guard let toolPicker: PKToolPicker = PKToolPicker.shared(for: window) else { return }
            toolPicker.setVisible(showTools, forFirstResponder: canvasView)
            if showTools {
                toolPicker.addObserver(canvasView)
                canvasView.becomeFirstResponder()
            }
        }
    }
    public var drawing: PKDrawing {
        get { canvasView.drawing }
        set { canvasView.drawing = newValue; setNeedsBuffer() }
    }
    public var allowsFingerDrawing: Bool {
        didSet {
            canvasView.allowsFingerDrawing = allowsFingerDrawing
        }
    }
    public var bgColor: LiveColor = .black {
        didSet {
            canvasView.backgroundColor = bgColor.uiColor
        }
    }
    
    public override var liveValues: [LiveValue] { [bgColor] }
    
    public override var postUniforms: [CGFloat] { [1/*flip*/, 1/*swapRB*/] }
    
    // MARK: - Interaction
    
    let pencilInteraction: UIPencilInteraction
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        canvasView = PKCanvasView()
        pencilInteraction = UIPencilInteraction()
        canvasView.addInteraction(pencilInteraction)
        allowsFingerDrawing = canvasView.allowsFingerDrawing
        helper = PaintHelper()
        super.init(name: "Paint", typeName: "pix-content-resource-paint")
        canvasView.backgroundColor = bgColor.uiColor
        canvasView.delegate = helper
        pencilInteraction.delegate = helper
        helper.paintedCallback = {
            self.setNeedsBuffer()
        }
        setFrame()
        setNeedsBuffer()
    }
    
    func setFrame() {
        canvasView.frame = CGRect(origin: .zero, size: resolution.size.cg)
    }
    
    public func clear() {
        drawing = PKDrawing()
    }
    
    public func listenToInteraction(_ callback: @escaping () -> ()) {
        helper.pencilInteractionCallback = callback
    }
    
    public func listenToPaint(_ callback: @escaping () -> ()) {
        helper.paintedExternalCallback = callback
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        let frame: CGRect = CGRect(origin: .zero, size: resolution.size.cg)
        let image: UIImage = drawing.image(from: frame, scale: 1.0)
        guard let cgImage: CGImage = image.cgImage else { return }
        guard let bits = LiveColor.Bits(rawValue: cgImage.bitsPerPixel) else { return }
        guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Paint Loaded.")
        applyResolution { self.setNeedsRender() }
    }
    
}

@available(iOS 13.0, *)
class PaintHelper: NSObject, PKCanvasViewDelegate, UIPencilInteractionDelegate {
    
    var paintedCallback: (() -> ())?
    var paintedExternalCallback: (() -> ())?
    var pencilInteractionCallback: (() -> ())?
    
    // MARK: - PKCanvasViewDelegate

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        paintedCallback?()
        paintedExternalCallback?()
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        paintedCallback?()
    }
    
    // MARK: - UIPencilInteractionDelegate
    
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
//        UIPencilInteraction.preferredTapAction == .
        pencilInteractionCallback?()
    }

}

#endif
