//
//  PIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-20.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import RenderKit
import Resolution
import CoreGraphics
import Metal
import simd
import Combine
#if os(iOS)
import UIKit
#endif
import PixelColor

open class PIX: NODE, ObservableObject, Equatable {
    
    @Published public var pixelModel: PixelModel {
        didSet {
            guard !liveUpdatingModel else { return }
            modelUpdated()
            render()
        }
    }
    private var liveUpdatingModel: Bool = false
    private var modelUpdatingLive: Bool = false
    
    public var renderObject: Render { PixelKit.main.render }
    
    public var id: UUID {
        get {
            pixelModel.id
        }
        set {
            pixelModel.id = newValue
        }
    }
    public var name: String {
        get { pixelModel.name }
        set { pixelModel.name = newValue }
    }
    public var typeName: String {
        pixelModel.typeName
    }
    
    public weak var delegate: NODEDelegate?
    
    @available(*, deprecated, renamed: "PixelKit.main")
    let pixelKit: PixelKit = PixelKit.main
    
    open var shaderName: String {
        typeName
            .replacingOccurrences(of: "pix-", with: "")
            .camelCased
            + "PIX"
    }
    
    open var overrideBits: Bits? { nil }
    
    open var liveList: [LiveWrap] { [] }
    open var values: [Floatable] { [] }
    open var extraUniforms: [CGFloat] { [] }
    open var uniforms: [CGFloat] {
        var uniforms: [CGFloat] = values.flatMap(\.floats)
        uniforms.append(contentsOf: extraUniforms)
        return uniforms
    }
    
    open var uniformArray: [[CGFloat]]? { nil }
    public var uniformArrayMaxLimit: Int? { nil }
    public var uniformArrayLength: Int? { nil }
    public var uniformIndexArray: [[Int]]? { nil }
    public var uniformIndexArrayMaxLimit: Int? { nil }
       
    
    @Published public var finalResolution: Resolution = PixelKit.main.fallbackResolution
    
    var customResolution: Resolution? { nil }
    
    
    public var clearColor: PixelColor = .clear {
        didSet {
            render()
        }
    }
    
    
    open var vertexUniforms: [CGFloat] { [] }
    public var shaderNeedsResolution: Bool { false }
    
    public var canRender: Bool = true
    
    public var bypass: Bool {
        get { pixelModel.bypass }
        set {
            pixelModel.bypass = newValue
            if newValue {
                if let nodeOut: NODEOutIO = self as? NODEOutIO {
                    for nodePath in nodeOut.outputPathList {
                        nodePath.nodeIn.render()
                    }
                }
            } else {
                render()                
            }
        }
    }

    public var _texture: MTLTexture?
    public var texture: MTLTexture? {
        get {
            guard !bypass else {
                guard let input = self as? NODEInIO else { return nil }
                return input.inputList.first?.texture
            }
            return _texture
        }
        set {
            _texture = newValue
            if newValue != nil {
                nextTextureAvailableCallback?()
            }
        }
    }
    public var didRenderTexture: Bool {
        _texture != nil
    }
    var nextTextureAvailableCallback: (() -> ())?
    public func nextTextureAvailable(_ callback: @escaping () -> ()) {
        nextTextureAvailableCallback = {
            callback()
            self.nextTextureAvailableCallback = nil
        }
    }
    
    open var additiveVertexBlending: Bool { false }
    
    public var pixView: PIXView!
    public var view: NODEView! { pixView }
    public var additionalViews: [NODEView] = []
    #if os(iOS)
    var viewController: UIViewController? {
        var parentResponder: UIResponder? = view
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    var presentedDownstreamPix: PIX? {
        var pix: PIX? = self
        while pix != nil {
            if pix?.view.superview != nil {
                return pix
            }
            if let pixOut: NODEOutIO = pix as? NODEOutIO {
                pix = pixOut.outputPathList.first?.nodeIn as? PIX
            } else {
                return nil
            }
        }
        return nil
    }
    #endif
    
    public var viewInterpolation: ViewInterpolation {
        get { pixelModel.viewInterpolation }
        set {
            pixelModel.viewInterpolation = newValue
            view.metalView.viewInterpolation = newValue
        }
    }
    @available(*, deprecated, renamed: "interpolation")
    public var interpolate: PixelInterpolation {
        get { interpolation }
        set { interpolation = newValue }
    }
    public var interpolation: PixelInterpolation {
        get { pixelModel.interpolation }
        set {
            pixelModel.interpolation = newValue
            updateSampler()
        }
    }
    public var extend: ExtendMode {
        get { pixelModel.extend }
        set {
            pixelModel.extend = newValue
            updateSampler()
        }
    }
    public var mipmap: MTLSamplerMipFilter = .linear { didSet { updateSampler() } }
    var compare: MTLCompareFunction = .never
    
    public var pipeline: MTLRenderPipelineState!
    public var sampler: MTLSamplerState!
    public var allGood: Bool {
        pipeline != nil && sampler != nil
    }
    
    public var customRenderActive: Bool = false
    public weak var customRenderDelegate: CustomRenderDelegate?
    public var customMergerRenderActive: Bool = false
    public weak var customMergerRenderDelegate: CustomMergerRenderDelegate?
    public var customGeometryActive: Bool = false
    public weak var customGeometryDelegate: CustomGeometryDelegate?
    open var customMetalLibrary: MTLLibrary? { nil }
    open var customVertexShaderName: String? { nil }
    open var customVertexTextureActive: Bool { false }
    open var customVertexNodeIn: (NODE & NODEOut)? { nil }
//    open var customVertexNodeIn: (NODE & NODEOut)?
    open var customMatrices: [matrix_float4x4] { [] }
//    public var customLinkedNodes: [NODE] = []
    
    public var renderInProgress = false
    public var renderQueue: [RenderRequest] = []
    public var renderIndex: Int = 0
    public var contentLoaded: Bool?
    var inputTextureAvailable: Bool?
    var generatorNotBypassed: Bool?
    
    static let metalLibrary: MTLLibrary = {
        do {
            return try PixelKit.main.render.metalDevice.makeDefaultLibrary(bundle: Bundle.module)
        } catch {
            fatalError("Loading Metal Library Failed: \(error.localizedDescription)")
        }
    }()
    
    public var destroyed = false
    public var cancellables: [AnyCancellable] = []
    
    // MARK: - Life Cycle -
    
    init(model: PixelModel) {
        pixelModel = model
        setupPIX()
    }
    
    // MARK: - Setup
    
    func setupPIX() {
        
        let pixelFormat: MTLPixelFormat = overrideBits?.pixelFormat ?? PixelKit.main.render.bits.pixelFormat
        pixView = PIXView(pix: self, with: PixelKit.main.render, pixelFormat: pixelFormat)
        
        setupShader()
            
        PixelKit.main.render.add(node: self)
        
        PixelKit.main.logger.log(node: self, .detail, nil, "Linked with PixelKit.", clean: true)
        
        for liveProp in liveList {
            liveProp.node = self
        }
        
    }
    
    func setupShader() {
        guard shaderName != "" else {
            PixelKit.main.logger.log(node: self, .fatal, nil, "Shader not defined.")
            return
        }
        do {
            if self is NODEMetal == false {
                guard let function: MTLFunction = (customMetalLibrary ?? PIX.metalLibrary).makeFunction(name: shaderName) else {
                    PixelKit.main.logger.log(node: self, .fatal, nil, "Setup of Metal Function \"\(shaderName)\" Failed")
                    return
                }
                var customVertexShader: MTLFunction? = nil
                if let metalLibrarry: MTLLibrary = customMetalLibrary, let vertexShaderName: String = customVertexShaderName {
                    customVertexShader = metalLibrarry.makeFunction(name: vertexShaderName)
                }
                pipeline = try PixelKit.main.render.makeShaderPipeline(function, with: customVertexShader, addMode: additiveVertexBlending, overrideBits: overrideBits)
            }
//            #if !os(tvOS) || !targetEnvironment(simulator)
            sampler = try PixelKit.main.render.makeSampler(interpolate: interpolation.mtl, extend: extend.mtl, mipFilter: mipmap)
//            #endif
        } catch {
            PixelKit.main.logger.log(node: self, .fatal, nil, "Setup Failed", e: error)
        }
    }
    
    // MARK: - Sampler
    
    func updateSampler() {
        do {
            #if !os(tvOS) || !targetEnvironment(simulator)
            sampler = try PixelKit.main.render.makeSampler(interpolate: interpolation.mtl, extend: extend.mtl, mipFilter: mipmap)
            #endif
            PixelKit.main.logger.log(node: self, .info, nil, "New Sample Mode. Interpolate: \(interpolation) & Extend: \(extend)")
            render()
        } catch {
            PixelKit.main.logger.log(node: self, .error, nil, "Error setting new Sample Mode. Interpolate: \(interpolation) & Extend: \(extend)", e: error)
        }
    }
    
    // MARK: - Model
    
    func modelUpdated() {
        guard !liveUpdatingModel else { return }
        modelUpdateLive()
    }
    
    /// Call `modelUpdateLiveDone()` in final class
    open func modelUpdateLive() {
        modelUpdatingLive = true
    }
    public func modelUpdateLiveDone() {
        modelUpdatingLive = false
    }
    
    // MARK: - Live
    
    public func liveValueChanged() {
        guard !modelUpdatingLive else { return }
        liveUpdateModel()
    }
    
    /// Call `liveUpdateModelDone()` in final class
    open func liveUpdateModel() {
        liveUpdatingModel = true
    }
    public func liveUpdateModelDone() {
        liveUpdatingModel = false
    }
    
    // MARK: - Render
    
    public func render() {
        guard renderObject.engine.renderMode == .auto else { return }
        renderObject.logger.log(node: self, .detail, .render, "Render Requested", loop: true)
        let renderRequest = RenderRequest(frameIndex: renderObject.frameIndex, node: self, completion: nil)
        queueRender(renderRequest)
    }
    
    open func didRender(renderPack: RenderPack) {
        self.texture = renderPack.response.texture
        renderIndex += 1
        delegate?.nodeDidRender(self)
        renderOuts(renderPack: renderPack)
        renderCustomVertexTexture()
    }
    
    public func clearRender() {
        texture = nil
        renderObject.logger.log(node: self, .info, .render, "Clear Render")
        removeRes()
    }
    
    // MARK: - Connect
    
    open func didConnect() {}
    
    open func didDisconnect() {
        removeRes()
    }
    
    // MARK: Equals
    
    public static func ==(lhs: PIX, rhs: PIX) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func !=(lhs: PIX, rhs: PIX) -> Bool {
        lhs.id != rhs.id
    }
    
    public static func ==(lhs: PIX?, rhs: PIX) -> Bool {
        guard lhs != nil else { return false }
        return lhs!.id == rhs.id
    }
    
    public static func !=(lhs: PIX?, rhs: PIX) -> Bool {
        guard lhs != nil else { return false }
        return lhs!.id != rhs.id
    }
    
    public static func ==(lhs: PIX, rhs: PIX?) -> Bool {
        guard rhs != nil else { return false }
        return lhs.id == rhs!.id
    }
    
    public static func !=(lhs: PIX, rhs: PIX?) -> Bool {
        guard rhs != nil else { return false }
        return lhs.id != rhs!.id
    }
    
    public func isEqual(to node: NODE) -> Bool {
        self.id == node.id
    }
    
    // MARK: Clean
    
    open func destroy() {
        clearRender()
        PixelKit.main.render.remove(node: self)
        texture = nil
        bypass = true
        destroyed = true
        view.destroy()
        PixelKit.main.logger.log(.info, .pixelKit, "Destroyed node(name: \(name), typeName: \(typeName), id: \(id))")
    }
}

public extension PIX {
    
    func addView() -> NODEView {
        addPixView()
    }
    
    func addPixView() -> PIXView {
        let pixelFormat: MTLPixelFormat = overrideBits?.pixelFormat ?? PixelKit.main.render.bits.pixelFormat
        let view = PIXView(pix: self, with: PixelKit.main.render, pixelFormat: pixelFormat)
        additionalViews.append(view)
        applyResolution { [weak self] in
            self?.render()
        }
        return view
    }
    
    func removeView(_ view: NODEView) {
        additionalViews.removeAll { nodeView in
            nodeView == view
        }
    }
    
}

public extension NODEOut where Self: PIX & NODEOut & PIXViewable {
    
    func pixBypass(_ value: Bool) -> PIX & NODEOut {
        bypass = value
        return self
    }
    
    func pixTransparentBackground() -> PIX & NODEOut {
        pixView.checker = false
        return self
    }
    
    func pixCheckerBackground() -> PIX & NODEOut {
        pixView.checker = true
        return self
    }
    
    /// Placement of the view.
    ///
    /// Default is `.fit`
    func pixPlacement(_ placement: Placement) -> PIX & NODEOut {
        view.placement = placement
        return self
    }
    
    /// Interpolate determins what happens inbetween scaled pixels.
    ///
    /// Default is `.linear`
    func pixInterpolate(_ interpolation: PixelInterpolation) -> PIX & NODEOut {
        self.interpolation = interpolation
        return self
    }
    
    /// Extend determins what happens to pixels outside of zero to one bounds.
    ///
    /// Default is `.zero`
    func pixExtend(_ extend: ExtendMode) -> PIX & NODEOut {
        self.extend = extend
        return self
    }
    
}
