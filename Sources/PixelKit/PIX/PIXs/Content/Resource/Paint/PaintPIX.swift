//
//  PaintPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-02-02.
//

#if os(iOS) && !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)

import RenderKit
import Resolution
import UIKit
import PencilKit
import PixelColor

@available(iOS 13.0, *)
final public class PaintPIX: PIXResource, NODEResolution, PIXViewable {
    
    public typealias Model = PaintPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { "backgroundPIX" }

    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    let helper: PaintHelper
    
    /// Used in external apps
    @Published public var stencilInput: (PIX & NODEOut)?
    
    public let canvasView: PKCanvasView = .init()
    
    public var manualToolUpdate: Bool {
        get { model.manualToolUpdate }
        set { model.manualToolUpdate = newValue }
    }
    
    public enum ToolType: String, Codable, CaseIterable {
        case inking
        case eraser
//        case lasso
    }
    public var toolType: ToolType {
        get { model.toolType }
        set {
            model.toolType = newValue
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    public enum InkType: String, Codable, CaseIterable {
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
    public var inkType: InkType {
        get { model.inkType }
        set {
            model.inkType = newValue
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    public var color: PixelColor {
        get { model.color }
        set {
            model.color = newValue
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    public var width: CGFloat {
        get { model.width }
        set {
            model.width = newValue
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    public enum EraserType: String, Codable, CaseIterable {
        case vector
        case bitmap
        public var eraserType: PKEraserTool.EraserType {
            switch self {
            case .vector: return .vector
            case .bitmap: return .bitmap
            }
        }
    }
    public var eraserType: EraserType {
        get { model.eraserType }
        set {
            model.eraserType = newValue
            guard !manualToolUpdate else { return }
            canvasView.tool = tool
        }
    }
    
    var tool: PKTool {
        switch toolType {
        case .inking:
            return PKInkingTool(inkType.inkType, color: color.uiColor, width: width)
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
            guard let window: UIWindow = canvasView.window else { return }
            showTools(showTools, in: window)
        }
    }
    public var drawing: PKDrawing {
        get { canvasView.drawing }
        set { canvasView.drawing = newValue; setNeedsBuffer() }
    }
    public var allowsFingerDrawing: Bool {
        get { model.allowsFingerDrawing }
        set {
            model.allowsFingerDrawing = newValue
            canvasView.allowsFingerDrawing = newValue
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
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        helper = PaintHelper()
        super.init(model: model)
        setup()
    }
    
    public init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        helper = PaintHelper()
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        helper = PaintHelper()
        super.init(model: model)
        setup()
    }
    
    // MARK: Codable
    
//    required init(from decoder: Decoder) throws {
//        canvasView.addInteraction(pencilInteraction)
//        helper = PaintHelper()
//        try super.init(from: decoder)
//        setup()
//    }
    
    // MARK: Setup
    
    func setup() {
        _resolution.didSetValue = { [weak self] in
            self?.setFrame()
            self?.applyResolution { [weak self] in
                self?.setNeedsBuffer()
            }
        }
        canvasView.addInteraction(pencilInteraction)
        canvasView.allowsFingerDrawing = model.allowsFingerDrawing
        canvasView.backgroundColor = backgroundColor.uiColor
        canvasView.delegate = helper
        pencilInteraction.delegate = helper
        helper.paintedCallback = { [weak self] in
            self?.setNeedsBuffer()
        }
        setFrame()
        setNeedsBuffer()
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        backgroundColor = model.backgroundColor
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        model.backgroundColor = backgroundColor
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Drawing
    
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
    
    public func showTools(_ active: Bool, in window: UIWindow) {
        guard let toolPicker: PKToolPicker = PKToolPicker.shared(for: window) else { return }
        toolPicker.setVisible(showTools, forFirstResponder: canvasView)
        if showTools {
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
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
