//
//  PaintPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-02-02.
//

#if os(iOS) && !targetEnvironment(macCatalyst)

import RenderKit
import Resolution
import UIKit
import PencilKit
import PixelColor

@available(iOS 13.0, *)
final public class PaintPIX: PIXResource, NODEResolution, PIXViewable {
    
    override public var shaderName: String { return "backgroundPIX" }

    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128 { didSet { setFrame(); applyResolution { [weak self] in self?.setNeedsBuffer() } } }
    
    let helper: PaintHelper
    
    public let canvasView: PKCanvasView = .init()
    
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
    public lazy var allowsFingerDrawing: Bool = canvasView.allowsFingerDrawing {
        didSet {
            canvasView.allowsFingerDrawing = allowsFingerDrawing
        }
    }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black {
        didSet {
            canvasView.backgroundColor = backgroundColor.uiColor
        }
    }
    
    public override var liveList: [LiveWrap] {
        [_resolution, _backgroundColor] + super.liveList
    }
    
    public override var values: [Floatable] { [backgroundColor] }
    
    public override var extraUniforms: [CGFloat] { [1/*flip*/, 1/*swapRB*/] }
    
    // MARK: - Interaction
    
    let pencilInteraction: UIPencilInteraction = .init()
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        canvasView.addInteraction(pencilInteraction)
        helper = PaintHelper()
        super.init(name: "Paint", typeName: "pix-content-resource-paint")
        setup()
    }
    
    public required convenience init() {
        self.init(at: .auto(render: PixelKit.main.render))
    }
    
    // MARK: Codable
    
    required init(from decoder: Decoder) throws {
        canvasView.addInteraction(pencilInteraction)
        helper = PaintHelper()
        try super.init(from: decoder)
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        canvasView.backgroundColor = backgroundColor.uiColor
        canvasView.delegate = helper
        pencilInteraction.delegate = helper
        helper.paintedCallback = { [weak self] in
            self?.setNeedsBuffer()
        }
        setFrame()
        setNeedsBuffer()
    }
    
    func setFrame() {
        canvasView.frame = CGRect(origin: .zero, size: resolution.size)
    }
    
    public func clearDrawing() {
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
        guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: ._8) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        resourcePixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Paint Loaded.")
        applyResolution { [weak self] in
            self?.render()
        }
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
