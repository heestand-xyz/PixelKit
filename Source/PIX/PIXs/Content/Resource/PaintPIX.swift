//
//  PaintPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-02-02.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import RenderKit
import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import PencilKit
import PixelColor

//#if canImport(SwiftUI)
//@available(iOS 13.0.0, *)
//public struct PaintPIXUI: View, PIXUI {
//    public var node: NODE { pix }
//    public let pix: PIX
//    let paintPix: PaintPIX
//    public var body: some View {
//        NODERepView(node: pix)
//    }
//    public init() {
//        paintPix = PaintPIX()
//        pix = paintPix
//    }
//}
//#endif

@available(iOS 13.0, *)
final public class PaintPIX: PIXResource, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "contentResourceBackgroundPIX" }

    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { setFrame(); applyResolution { self.setNeedsBuffer() } } }
    
    let helper: PaintHelper
    
    public let canvasView: PKCanvasView
    
    public var manualToolUpdate: Bool = false
    
    public enum ToolType: String, CaseIterable {
        case inking
        case eraser
//        case lasso
    }
    public var toolType: ToolType = .inking {
        didSet {
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    public enum InkType: String, CaseIterable {
        case marker
        case pen
        case pencil
        public var inkType: PKInkingTool.InkType {
            switch self {
            case .marker: return .marker
            case .pen: return .pen
            case .pencil: return .pencil
            }
        }
    }
    public var inkType: InkType = .pen {
        didSet {
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    public var color: UIColor = .white {
        didSet {
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    public var width: CGFloat = 10 {
        didSet {
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    public enum EraserType: String, CaseIterable {
        case vector
        case bitmap
        public var eraserType: PKEraserTool.EraserType {
            switch self {
            case .vector: return .vector
            case .bitmap: return .bitmap
            }
        }
    }
    public var eraserType: EraserType = .vector {
        didSet {
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    var tool: PKTool {
        switch toolType {
        case .inking:
            return PKInkingTool(inkType.inkType, color: color, width: width)
        case .eraser:
            return PKEraserTool(eraserType.eraserType)
//        case .lasso:
//            return PKLassoTool()
        }
    }

    public var isRulerActive: Bool {
        get { canvasView.isRulerActive }
        set { canvasView.isRulerActive = newValue }
    }
    
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
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    public var backgroundColor: PixelColor = .black {
        didSet {
            canvasView.backgroundColor = backgroundColor.uiColor
        }
    }
    
    public override var values: [Floatable] { [backgroundColor] }
    
    public override var extraUniforms: [CGFloat] { [1/*flip*/, 1/*swapRB*/] }
    
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
        canvasView.backgroundColor = backgroundColor.uiColor
        canvasView.delegate = helper
        pencilInteraction.delegate = helper
        helper.paintedCallback = {
            self.setNeedsBuffer()
        }
        setFrame()
        setNeedsBuffer()
    }
    
    func setFrame() {
        canvasView.frame = CGRect(origin: .zero, size: resolution.size)
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
        let frame: CGRect = CGRect(origin: .zero, size: resolution.size)
        let image: UIImage = drawing.image(from: frame, scale: 1.0)
        guard let cgImage: CGImage = image.cgImage else { return }
        guard let bits = Bits(rawValue: cgImage.bitsPerPixel) else { return }
        guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        resourcePixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Paint Loaded.")
        applyResolution { self.setNeedsRender() }
    }
    
    public func updateTool() {
        canvasView.tool = tool
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
