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
    
    private var liveUpdatingModel: Bool = false
    @Published public var pixelModel: PixelModel {
        didSet {
            guard !liveUpdatingModel else { return }
            modelUpdated()
            render()
        }
    }
    
    public var renderObject: Render { PixelKit.main.render }
    
    public var id: UUID {
        pixelModel.id
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
    
    
    open var vertexUniforms: [CGFloat] { return [] }
    public var shaderNeedsResolution: Bool { return false }
    
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
        return _texture != nil
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
        return pipeline != nil && sampler != nil
    }
    
    public var customRenderActive: Bool = false
    public weak var customRenderDelegate: CustomRenderDelegate?
    public var customMergerRenderActive: Bool = false
    public weak var customMergerRenderDelegate: CustomMergerRenderDelegate?
    public var customGeometryActive: Bool = false
    public weak var customGeometryDelegate: CustomGeometryDelegate?
    open var customMetalLibrary: MTLLibrary? { return nil }
    open var customVertexShaderName: String? { return nil }
    open var customVertexTextureActive: Bool { return false }
    open var customVertexNodeIn: (NODE & NODEOut)? { return nil }
//    open var customVertexNodeIn: (NODE & NODEOut)?
    open var customMatrices: [matrix_float4x4] { return [] }
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
        modelUpdateLive()
    }
    
    // MARK: - Live
    
    public func liveValueChanged() {
        liveUpdateModel()
    }
    
    /// Call `liveUpdateModelDone()` in final class
    func liveUpdateModel() {
        liveUpdatingModel = true
    }
    func liveUpdateModelDone() {
        liveUpdatingModel = false
    }
    
    /// Call `modelUpdateLiveDone()` in final class
    func modelUpdateLive() {}
    func modelUpdateLiveDone() {}
    
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
        return lhs.id == rhs.id
    }
    
    public static func !=(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id != rhs.id
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
    
    // MARK: Codable
    
    public enum CodingError: Error {
        case typeNameUnknown(String)
        case badOS
        case badOSVersion
    }
    
    public func encodePixelModel() throws -> Data {

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        for type in PIXCustomType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .scene:
                return try encoder.encode(pixelModel as! ScenePixelModel)
            }
        }

        for type in PIXGeneratorType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .arc:
                return try encoder.encode(pixelModel as! ArcPixelModel)
            case .circle:
                return try encoder.encode(pixelModel as! CirclePixelModel)
            case .color:
                return try encoder.encode(pixelModel as! ColorPixelModel)
            case .gradient:
                return try encoder.encode(pixelModel as! GradientPixelModel)
            case .line:
                return try encoder.encode(pixelModel as! LinePixelModel)
            case .metal:
                return try encoder.encode(pixelModel as! MetalPixelModel)
            case .metalScript:
                return try encoder.encode(pixelModel as! MetalScriptPixelModel)
            case .noise:
                return try encoder.encode(pixelModel as! NoisePixelModel)
            case .polygon:
                return try encoder.encode(pixelModel as! PolygonPixelModel)
            case .rectangle:
                return try encoder.encode(pixelModel as! RectanglePixelModel)
            case .star:
                return try encoder.encode(pixelModel as! StarPixelModel)
            }
        }
        
        for type in PIXResourceType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .camera:
                #if !os(tvOS)
                return try encoder.encode(pixelModel as! CameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .image:
                return try encoder.encode(pixelModel as! ImagePixelModel)
            case .vector:
                #if !os(tvOS)
                return try encoder.encode(pixelModel as! VectorPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .video:
                return try encoder.encode(pixelModel as! VideoPixelModel)
            case .view:
                return try encoder.encode(pixelModel as! ViewPixelModel)
            case .web:
                #if !os(tvOS)
                return try encoder.encode(pixelModel as! WebPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .screenCapture:
                #if os(macOS) && !targetEnvironment(macCatalyst)
                return try encoder.encode(pixelModel as! ScreenCapturePixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .depthCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return try encoder.encode(pixelModel as! DepthCameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .multiCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return try encoder.encode(pixelModel as! MultiCameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .paint:
                #if os(iOS) && !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
                return try encoder.encode(pixelModel as! PaintPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .streamIn:
                #if os(iOS)
                return try encoder.encode(pixelModel as! StreamInPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .maps:
                return try encoder.encode(pixelModel as! EarthPixelModel)
            }
        }
        
        for type in PIXSpriteType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .text:
                return try encoder.encode(pixelModel as! TextPixelModel)
            }
        }
        
        for type in PIXSingleEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .average:
                return try encoder.encode(pixelModel as! AveragePixelModel)
            case .blur:
                return try encoder.encode(pixelModel as! BlurPixelModel)
            case .cache:
                return try encoder.encode(pixelModel as! CachePixelModel)
            case .channelMix:
                return try encoder.encode(pixelModel as! ChannelMixPixelModel)
            case .chromaKey:
                return try encoder.encode(pixelModel as! ChromaKeyPixelModel)
            case .clamp:
                return try encoder.encode(pixelModel as! ClampPixelModel)
            case .colorConvert:
                return try encoder.encode(pixelModel as! ColorConvertPixelModel)
            case .colorCorrect:
                return try encoder.encode(pixelModel as! ColorCorrectPixelModel)
            case .colorShift:
                return try encoder.encode(pixelModel as! ColorShiftPixelModel)
            case .convert:
                return try encoder.encode(pixelModel as! ConvertPixelModel)
            case .cornerPin:
                return try encoder.encode(pixelModel as! CornerPinPixelModel)
            case .crop:
                return try encoder.encode(pixelModel as! CropPixelModel)
            case .delay:
                return try encoder.encode(pixelModel as! DelayPixelModel)
            case .distance:
                return try encoder.encode(pixelModel as! DistancePixelModel)
            case .edge:
                return try encoder.encode(pixelModel as! EdgePixelModel)
            case .feedback:
                return try encoder.encode(pixelModel as! FeedbackPixelModel)
            case .flare:
                return try encoder.encode(pixelModel as! FlarePixelModel)
            case .flipFlop:
                return try encoder.encode(pixelModel as! FlipFlopPixelModel)
            case .freeze:
                return try encoder.encode(pixelModel as! FreezePixelModel)
            case .equalize:
                return try encoder.encode(pixelModel as! EqualizePixelModel)
            case .kaleidoscope:
                return try encoder.encode(pixelModel as! KaleidoscopePixelModel)
            case .levels:
                return try encoder.encode(pixelModel as! LevelsPixelModel)
            case .metalEffect:
                return try encoder.encode(pixelModel as! MetalEffectPixelModel)
            case .metalScriptEffect:
                return try encoder.encode(pixelModel as! MetalScriptEffectPixelModel)
            case .morph:
                return try encoder.encode(pixelModel as! MorphPixelModel)
            case .nil:
                return try encoder.encode(pixelModel as! NilPixelModel)
            case .quantize:
                return try encoder.encode(pixelModel as! QuantizePixelModel)
            case .rainbowBlur:
                return try encoder.encode(pixelModel as! RainbowBlurPixelModel)
            case .range:
                return try encoder.encode(pixelModel as! RangePixelModel)
            case .reduce:
                return try encoder.encode(pixelModel as! ReducePixelModel)
            case .resolution:
                return try encoder.encode(pixelModel as! ResolutionPixelModel)
            case .saliency:
                return try encoder.encode(pixelModel as! SaliencyPixelModel)
            case .sepia:
                return try encoder.encode(pixelModel as! SepiaPixelModel)
            case .sharpen:
                return try encoder.encode(pixelModel as! SharpenPixelModel)
            case .slice:
                return try encoder.encode(pixelModel as! SlicePixelModel)
            case .slope:
                return try encoder.encode(pixelModel as! SlopePixelModel)
            case .threshold:
                return try encoder.encode(pixelModel as! ThresholdPixelModel)
            case .tint:
                return try encoder.encode(pixelModel as! TintPixelModel)
            case .transform:
                return try encoder.encode(pixelModel as! TransformPixelModel)
            case .twirl:
                return try encoder.encode(pixelModel as! TwirlPixelModel)
            case .opticalFlow:
                return try encoder.encode(pixelModel as! OpticalFlowPixelModel)
            case .filter:
                return try encoder.encode(pixelModel as! FilterPixelModel)
            case .warp:
                return try encoder.encode(pixelModel as! WarpPixelModel)
            case .pixelate:
                return try encoder.encode(pixelModel as! PixelatePixelModel)
            }
        }
        
        for type in PIXMergerEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .blend:
                return try encoder.encode(pixelModel as! BlendPixelModel)
            case .cross:
                return try encoder.encode(pixelModel as! CrossPixelModel)
            case .displace:
                return try encoder.encode(pixelModel as! DisplacePixelModel)
            case .lookup:
                return try encoder.encode(pixelModel as! LookupPixelModel)
            case .lumaBlur:
                return try encoder.encode(pixelModel as! LumaBlurPixelModel)
            case .lumaColorShift:
                return try encoder.encode(pixelModel as! LumaColorShiftPixelModel)
            case .lumaLevels:
                return try encoder.encode(pixelModel as! LumaLevelsPixelModel)
            case .lumaRainbowBlur:
                return try encoder.encode(pixelModel as! LumaRainbowBlurPixelModel)
            case .lumaTransform:
                return try encoder.encode(pixelModel as! LumaTransformPixelModel)
            case .metalMergerEffect:
                return try encoder.encode(pixelModel as! MetalMergerEffectPixelModel)
            case .metalScriptMergerEffect:
                return try encoder.encode(pixelModel as! MetalScriptMergerEffectPixelModel)
            case .remap:
                return try encoder.encode(pixelModel as! RemapPixelModel)
            case .reorder:
                return try encoder.encode(pixelModel as! ReorderPixelModel)
            case .timeMachine:
                return try encoder.encode(pixelModel as! TimeMachinePixelModel)
            }
        }
        
        for type in PIXMultiEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .array:
                return try encoder.encode(pixelModel as! ArrayPixelModel)
            case .blends:
                return try encoder.encode(pixelModel as! BlendsPixelModel)
            case .metalMultiEffect:
                return try encoder.encode(pixelModel as! MetalMultiEffectPixelModel)
            case .metalScriptMultiEffect:
                return try encoder.encode(pixelModel as! MetalScriptMultiEffectPixelModel)
            case .stack:
                return try encoder.encode(pixelModel as! StackPixelModel)
            case .textureParticles:
                return try encoder.encode(pixelModel as! TextureParticlesPixelModel)
            case .instancer:
                return try encoder.encode(pixelModel as! InstancerPixelModel)
            }
        }
        
        for type in PIXOutputType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .record:
                return try encoder.encode(pixelModel as! RecordPixelModel)
            case .airPlay:
                #if os(iOS)
                return try encoder.encode(pixelModel as! AirPlayPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .streamOut:
                #if os(iOS)
                return try encoder.encode(pixelModel as! StreamOutPixelModel)
                #else
                throw CodingError.badOS
                #endif
            }
        }

        throw CodingError.typeNameUnknown(typeName)
    }
    
    struct TypeNameContainer: Decodable {
        let typeName: String
    }
    
    public static func decodePixelModel(data: Data) throws -> PixelModel {
        
        let decoder = JSONDecoder()
        
        let typeNameContainer = try decoder.decode(TypeNameContainer.self, from: data)
        let typeName: String = typeNameContainer.typeName
                
        for type in PIXCustomType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .scene:
                return try decoder.decode(ScenePixelModel.self, from: data)
            }
        }

        for type in PIXGeneratorType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .arc:
                return try decoder.decode(ArcPixelModel.self, from: data)
            case .circle:
                return try decoder.decode(CirclePixelModel.self, from: data)
            case .color:
                return try decoder.decode(ColorPixelModel.self, from: data)
            case .gradient:
                return try decoder.decode(GradientPixelModel.self, from: data)
            case .line:
                return try decoder.decode(LinePixelModel.self, from: data)
            case .metal:
                return try decoder.decode(MetalPixelModel.self, from: data)
            case .metalScript:
                return try decoder.decode(MetalScriptPixelModel.self, from: data)
            case .noise:
                return try decoder.decode(NoisePixelModel.self, from: data)
            case .polygon:
                return try decoder.decode(PolygonPixelModel.self, from: data)
            case .rectangle:
                return try decoder.decode(RectanglePixelModel.self, from: data)
            case .star:
                return try decoder.decode(StarPixelModel.self, from: data)
            }
        }
        
        for type in PIXResourceType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .camera:
                #if !os(tvOS)
                return try decoder.decode(CameraPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .image:
                return try decoder.decode(ImagePixelModel.self, from: data)
            case .vector:
                #if !os(tvOS)
                return try decoder.decode(VectorPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .video:
                return try decoder.decode(VideoPixelModel.self, from: data)
            case .view:
                return try decoder.decode(ViewPixelModel.self, from: data)
            case .web:
                #if !os(tvOS)
                return try decoder.decode(WebPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .screenCapture:
                #if os(macOS) && !targetEnvironment(macCatalyst)
                return try decoder.decode(ScreenCapturePixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .depthCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return try decoder.decode(DepthCameraPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .multiCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return try decoder.decode(MultiCameraPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .paint:
                #if os(iOS) && !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
                return try decoder.decode(PaintPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .streamIn:
                #if os(iOS)
                return try decoder.decode(StreamInPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .maps:
                return try decoder.decode(EarthPixelModel.self, from: data)
            }
        }
        
        for type in PIXSpriteType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .text:
                return try decoder.decode(TextPixelModel.self, from: data)
            }
        }
        
        for type in PIXSingleEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .average:
                return try decoder.decode(AveragePixelModel.self, from: data)
            case .blur:
                return try decoder.decode(BlurPixelModel.self, from: data)
            case .cache:
                return try decoder.decode(CachePixelModel.self, from: data)
            case .channelMix:
                return try decoder.decode(ChannelMixPixelModel.self, from: data)
            case .chromaKey:
                return try decoder.decode(ChromaKeyPixelModel.self, from: data)
            case .clamp:
                return try decoder.decode(ClampPixelModel.self, from: data)
            case .colorConvert:
                return try decoder.decode(ColorConvertPixelModel.self, from: data)
            case .colorCorrect:
                return try decoder.decode(ColorCorrectPixelModel.self, from: data)
            case .colorShift:
                return try decoder.decode(ColorShiftPixelModel.self, from: data)
            case .convert:
                return try decoder.decode(ConvertPixelModel.self, from: data)
            case .cornerPin:
                return try decoder.decode(CornerPinPixelModel.self, from: data)
            case .crop:
                return try decoder.decode(CropPixelModel.self, from: data)
            case .delay:
                return try decoder.decode(DelayPixelModel.self, from: data)
            case .distance:
                return try decoder.decode(DistancePixelModel.self, from: data)
            case .edge:
                return try decoder.decode(EdgePixelModel.self, from: data)
            case .feedback:
                return try decoder.decode(FeedbackPixelModel.self, from: data)
            case .flare:
                return try decoder.decode(FlarePixelModel.self, from: data)
            case .flipFlop:
                return try decoder.decode(FlipFlopPixelModel.self, from: data)
            case .freeze:
                return try decoder.decode(FreezePixelModel.self, from: data)
            case .equalize:
                return try decoder.decode(EqualizePixelModel.self, from: data)
            case .kaleidoscope:
                return try decoder.decode(KaleidoscopePixelModel.self, from: data)
            case .levels:
                return try decoder.decode(LevelsPixelModel.self, from: data)
            case .metalEffect:
                return try decoder.decode(MetalEffectPixelModel.self, from: data)
            case .metalScriptEffect:
                return try decoder.decode(MetalScriptEffectPixelModel.self, from: data)
            case .morph:
                return try decoder.decode(MorphPixelModel.self, from: data)
            case .nil:
                return try decoder.decode(NilPixelModel.self, from: data)
            case .quantize:
                return try decoder.decode(QuantizePixelModel.self, from: data)
            case .rainbowBlur:
                return try decoder.decode(RainbowBlurPixelModel.self, from: data)
            case .range:
                return try decoder.decode(RangePixelModel.self, from: data)
            case .reduce:
                return try decoder.decode(ReducePixelModel.self, from: data)
            case .resolution:
                return try decoder.decode(ResolutionPixelModel.self, from: data)
            case .saliency:
                return try decoder.decode(SaliencyPixelModel.self, from: data)
            case .sepia:
                return try decoder.decode(SepiaPixelModel.self, from: data)
            case .sharpen:
                return try decoder.decode(SharpenPixelModel.self, from: data)
            case .slice:
                return try decoder.decode(SlicePixelModel.self, from: data)
            case .slope:
                return try decoder.decode(SlopePixelModel.self, from: data)
            case .threshold:
                return try decoder.decode(ThresholdPixelModel.self, from: data)
            case .tint:
                return try decoder.decode(TintPixelModel.self, from: data)
            case .transform:
                return try decoder.decode(TransformPixelModel.self, from: data)
            case .twirl:
                return try decoder.decode(TwirlPixelModel.self, from: data)
            case .opticalFlow:
                return try decoder.decode(OpticalFlowPixelModel.self, from: data)
            case .filter:
                return try decoder.decode(FilterPixelModel.self, from: data)
            case .warp:
                return try decoder.decode(WarpPixelModel.self, from: data)
            case .pixelate:
                return try decoder.decode(PixelatePixelModel.self, from: data)
            }
        }
        
        for type in PIXMergerEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .blend:
                return try decoder.decode(BlendPixelModel.self, from: data)
            case .cross:
                return try decoder.decode(CrossPixelModel.self, from: data)
            case .displace:
                return try decoder.decode(DisplacePixelModel.self, from: data)
            case .lookup:
                return try decoder.decode(LookupPixelModel.self, from: data)
            case .lumaBlur:
                return try decoder.decode(LumaBlurPixelModel.self, from: data)
            case .lumaColorShift:
                return try decoder.decode(LumaColorShiftPixelModel.self, from: data)
            case .lumaLevels:
                return try decoder.decode(LumaLevelsPixelModel.self, from: data)
            case .lumaRainbowBlur:
                return try decoder.decode(LumaRainbowBlurPixelModel.self, from: data)
            case .lumaTransform:
                return try decoder.decode(LumaTransformPixelModel.self, from: data)
            case .metalMergerEffect:
                return try decoder.decode(MetalMergerEffectPixelModel.self, from: data)
            case .metalScriptMergerEffect:
                return try decoder.decode(MetalScriptMergerEffectPixelModel.self, from: data)
            case .remap:
                return try decoder.decode(RemapPixelModel.self, from: data)
            case .reorder:
                return try decoder.decode(ReorderPixelModel.self, from: data)
            case .timeMachine:
                return try decoder.decode(TimeMachinePixelModel.self, from: data)
            }
        }
        
        for type in PIXMultiEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .array:
                return try decoder.decode(ArrayPixelModel.self, from: data)
            case .blends:
                return try decoder.decode(BlendsPixelModel.self, from: data)
            case .metalMultiEffect:
                return try decoder.decode(MetalMultiEffectPixelModel.self, from: data)
            case .metalScriptMultiEffect:
                return try decoder.decode(MetalScriptMultiEffectPixelModel.self, from: data)
            case .stack:
                return try decoder.decode(StackPixelModel.self, from: data)
            case .textureParticles:
                return try decoder.decode(TextureParticlesPixelModel.self, from: data)
            case .instancer:
                return try decoder.decode(InstancerPixelModel.self, from: data)
            }
        }
        
        for type in PIXOutputType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .record:
                return try decoder.decode(RecordPixelModel.self, from: data)
            case .airPlay:
                #if os(iOS)
                return try decoder.decode(AirPlayPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            case .streamOut:
                #if os(iOS)
                return try decoder.decode(StreamOutPixelModel.self, from: data)
                #else
                throw CodingError.badOS
                #endif
            }
        }
        
        throw CodingError.typeNameUnknown(typeName)
    }
    
    // MARK: - Initialize
    
    public static func initialize(pixelModel: PixelModel) throws -> PIX {
        
        let typeName: String = pixelModel.typeName
        
        for type in PIXCustomType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .scene:
                return ScenePIX(model: pixelModel as! ScenePixelModel)
            }
        }

        for type in PIXGeneratorType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .arc:
                return ArcPIX(model: pixelModel as! ArcPixelModel)
            case .circle:
                return CirclePIX(model: pixelModel as! CirclePixelModel)
            case .color:
                return ColorPIX(model: pixelModel as! ColorPixelModel)
            case .gradient:
                return GradientPIX(model: pixelModel as! GradientPixelModel)
            case .line:
                return LinePIX(model: pixelModel as! LinePixelModel)
            case .metal:
                return MetalPIX(model: pixelModel as! MetalPixelModel)
            case .metalScript:
                return MetalScriptPIX(model: pixelModel as! MetalScriptPixelModel)
            case .noise:
                return NoisePIX(model: pixelModel as! NoisePixelModel)
            case .polygon:
                return PolygonPIX(model: pixelModel as! PolygonPixelModel)
            case .rectangle:
                return RectanglePIX(model: pixelModel as! RectanglePixelModel)
            case .star:
                return StarPIX(model: pixelModel as! StarPixelModel)
            }
        }
        
        for type in PIXResourceType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .camera:
                #if !os(tvOS)
                return CameraPIX(model: pixelModel as! CameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .image:
                return ImagePIX(model: pixelModel as! ImagePixelModel)
            case .vector:
                #if !os(tvOS)
                return VectorPIX(model: pixelModel as! VectorPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .video:
                return VideoPIX(model: pixelModel as! VideoPixelModel)
            case .view:
                return ViewPIX(model: pixelModel as! ViewPixelModel)
            case .web:
                #if !os(tvOS)
                return WebPIX(model: pixelModel as! WebPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .screenCapture:
                #if os(macOS) && !targetEnvironment(macCatalyst)
                return ScreenCapturePIX(model: pixelModel as! ScreenCapturePixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .depthCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return DepthCameraPIX(model: pixelModel as! DepthCameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .multiCamera:
                #if os(iOS) && !targetEnvironment(macCatalyst)
                return MultiCameraPIX(model: pixelModel as! MultiCameraPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .paint:
                #if os(iOS) && !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
                return PaintPIX(model: pixelModel as! PaintPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .streamIn:
                #if os(iOS)
                return StreamInPIX(model: pixelModel as! StreamInPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .maps:
                return EarthPIX(model: pixelModel as! EarthPixelModel)
            }
        }
        
        for type in PIXSpriteType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .text:
                return TextPIX(model: pixelModel as! TextPixelModel)
            }
        }
        
        for type in PIXSingleEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .average:
                return AveragePIX(model: pixelModel as! AveragePixelModel)
            case .blur:
                return BlurPIX(model: pixelModel as! BlurPixelModel)
            case .cache:
                return CachePIX(model: pixelModel as! CachePixelModel)
            case .channelMix:
                return ChannelMixPIX(model: pixelModel as! ChannelMixPixelModel)
            case .chromaKey:
                return ChromaKeyPIX(model: pixelModel as! ChromaKeyPixelModel)
            case .clamp:
                return ClampPIX(model: pixelModel as! ClampPixelModel)
            case .colorConvert:
                return ColorConvertPIX(model: pixelModel as! ColorConvertPixelModel)
            case .colorCorrect:
                return ColorCorrectPIX(model: pixelModel as! ColorCorrectPixelModel)
            case .colorShift:
                return ColorShiftPIX(model: pixelModel as! ColorShiftPixelModel)
            case .convert:
                return ConvertPIX(model: pixelModel as! ConvertPixelModel)
            case .cornerPin:
                return CornerPinPIX(model: pixelModel as! CornerPinPixelModel)
            case .crop:
                return CropPIX(model: pixelModel as! CropPixelModel)
            case .delay:
                return DelayPIX(model: pixelModel as! DelayPixelModel)
            case .distance:
                return DistancePIX(model: pixelModel as! DistancePixelModel)
            case .edge:
                return EdgePIX(model: pixelModel as! EdgePixelModel)
            case .feedback:
                return FeedbackPIX(model: pixelModel as! FeedbackPixelModel)
            case .flare:
                return FlarePIX(model: pixelModel as! FlarePixelModel)
            case .flipFlop:
                return FlipFlopPIX(model: pixelModel as! FlipFlopPixelModel)
            case .freeze:
                return FreezePIX(model: pixelModel as! FreezePixelModel)
            case .equalize:
                return EqualizePIX(model: pixelModel as! EqualizePixelModel)
            case .kaleidoscope:
                return KaleidoscopePIX(model: pixelModel as! KaleidoscopePixelModel)
            case .levels:
                return LevelsPIX(model: pixelModel as! LevelsPixelModel)
            case .metalEffect:
                return MetalEffectPIX(model: pixelModel as! MetalEffectPixelModel)
            case .metalScriptEffect:
                return MetalScriptEffectPIX(model: pixelModel as! MetalScriptEffectPixelModel)
            case .morph:
                return MorphPIX(model: pixelModel as! MorphPixelModel)
            case .nil:
                return NilPIX(model: pixelModel as! NilPixelModel)
            case .quantize:
                return QuantizePIX(model: pixelModel as! QuantizePixelModel)
            case .rainbowBlur:
                return RainbowBlurPIX(model: pixelModel as! RainbowBlurPixelModel)
            case .range:
                return RangePIX(model: pixelModel as! RangePixelModel)
            case .reduce:
                return ReducePIX(model: pixelModel as! ReducePixelModel)
            case .resolution:
                return ResolutionPIX(model: pixelModel as! ResolutionPixelModel)
            case .saliency:
                return SaliencyPIX(model: pixelModel as! SaliencyPixelModel)
            case .sepia:
                return SepiaPIX(model: pixelModel as! SepiaPixelModel)
            case .sharpen:
                return SharpenPIX(model: pixelModel as! SharpenPixelModel)
            case .slice:
                return SlicePIX(model: pixelModel as! SlicePixelModel)
            case .slope:
                return SlopePIX(model: pixelModel as! SlopePixelModel)
            case .threshold:
                return ThresholdPIX(model: pixelModel as! ThresholdPixelModel)
            case .tint:
                return TintPIX(model: pixelModel as! TintPixelModel)
            case .transform:
                return TransformPIX(model: pixelModel as! TransformPixelModel)
            case .twirl:
                return TwirlPIX(model: pixelModel as! TwirlPixelModel)
            case .opticalFlow:
                if #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) {
                    return OpticalFlowPIX(model: pixelModel as! OpticalFlowPixelModel)
                } else {
                    throw CodingError.badOSVersion
                }
            case .filter:
                return FilterPIX(model: pixelModel as! FilterPixelModel)
            case .warp:
                return WarpPIX(model: pixelModel as! WarpPixelModel)
            case .pixelate:
                return PixelatePIX(model: pixelModel as! PixelatePixelModel)
            }
        }
        
        for type in PIXMergerEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .blend:
                return BlendPIX(model: pixelModel as! BlendPixelModel)
            case .cross:
                return CrossPIX(model: pixelModel as! CrossPixelModel)
            case .displace:
                return DisplacePIX(model: pixelModel as! DisplacePixelModel)
            case .lookup:
                return LookupPIX(model: pixelModel as! LookupPixelModel)
            case .lumaBlur:
                return LumaBlurPIX(model: pixelModel as! LumaBlurPixelModel)
            case .lumaColorShift:
                return LumaColorShiftPIX(model: pixelModel as! LumaColorShiftPixelModel)
            case .lumaLevels:
                return LumaLevelsPIX(model: pixelModel as! LumaLevelsPixelModel)
            case .lumaRainbowBlur:
                return LumaRainbowBlurPIX(model: pixelModel as! LumaRainbowBlurPixelModel)
            case .lumaTransform:
                return LumaTransformPIX(model: pixelModel as! LumaTransformPixelModel)
            case .metalMergerEffect:
                return MetalMergerEffectPIX(model: pixelModel as! MetalMergerEffectPixelModel)
            case .metalScriptMergerEffect:
                return MetalScriptMergerEffectPIX(model: pixelModel as! MetalScriptMergerEffectPixelModel)
            case .remap:
                return RemapPIX(model: pixelModel as! RemapPixelModel)
            case .reorder:
                return ReorderPIX(model: pixelModel as! ReorderPixelModel)
            case .timeMachine:
                return TimeMachinePIX(model: pixelModel as! TimeMachinePixelModel)
            }
        }
        
        for type in PIXMultiEffectType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .array:
                return ArrayPIX(model: pixelModel as! ArrayPixelModel)
            case .blends:
                return BlendsPIX(model: pixelModel as! BlendsPixelModel)
            case .metalMultiEffect:
                return MetalMultiEffectPIX(model: pixelModel as! MetalMultiEffectPixelModel)
            case .metalScriptMultiEffect:
                return MetalScriptMultiEffectPIX(model: pixelModel as! MetalScriptMultiEffectPixelModel)
            case .stack:
                return StackPIX(model: pixelModel as! StackPixelModel)
            case .textureParticles:
                return TextureParticlesPIX(model: pixelModel as! TextureParticlesPixelModel)
            case .instancer:
                return InstancerPIX(model: pixelModel as! InstancerPixelModel)
            }
        }
        
        for type in PIXOutputType.allCases {
            guard type.typeName == typeName else { continue }
            switch type {
            case .record:
                return RecordPIX(model: pixelModel as! RecordPixelModel)
            case .airPlay:
                #if os(iOS)
                return AirPlayPIX(model: pixelModel as! AirPlayPixelModel)
                #else
                throw CodingError.badOS
                #endif
            case .streamOut:
                #if os(iOS)
                return StreamOutPIX(model: pixelModel as! StreamOutPixelModel)
                #else
                throw CodingError.badOS
                #endif
            }
        }
        
        throw CodingError.typeNameUnknown(typeName)
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
