//
//  BlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-02.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import CoreGraphics
import MetalKit
#if !os(tvOS) && !targetEnvironment(simulator)
// MPS does not support the iOS simulator.
import MetalPerformanceShaders
#endif

final public class BlurPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    public typealias Model = BlurPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleBlurPIX" }
    
    // MARK: - Public Properties
    
    /// Gaussian blur is the most performant, tho it's not supported in the simulator.
    public enum BlurStyle: String, Enumable {
        case gaussian
        case box
        case angle
        case zoom
        case random
        public static let `default`: BlurStyle = {
            #if !os(tvOS) && !targetEnvironment(simulator)
            return .gaussian
            #else
            return .box
            #endif
        }()
        public var index: Int {
            switch self {
            case .gaussian: return 0
            case .box: return 1
            case .angle: return 2
            case .zoom: return 3
            case .random: return 4
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .gaussian: return "Guassian"
            case .box: return "Box"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            case .random: return "Random"
            }
        }
    }
    
    @LiveEnum("style") public var style: BlurStyle = .default
    /// radius is relative. default at 0.5
    ///
    /// 1.0 at 4K is max, tho at lower resolutions you can go beyond 1.0
    @LiveFloat("radius", increment: 0.125) public var radius: CGFloat = 0.5
    @LiveEnum("quality") public var quality: SampleQualityMode = .mid
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position]
    }
    
    var relRadius: CGFloat {
        let radius = self.radius
        let relRes: Resolution = ._4K
        let res: Resolution = finalResolution
        let relHeight = res.height / relRes.height
        let relRadius = radius * relHeight
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius
    }
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    override public var shaderNeedsResolution: Bool { return true }
    
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
    
    // MARK: Setup
    
    private func setup() {
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        style = model.style
        radius = model.radius
        quality = model.quality
        angle = model.angle
        position = model.position
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.style = style
        model.radius = radius
        model.quality = quality
        model.angle = angle
        model.position = position
        
        super.liveUpdateModelDone()
    }
    
    // MARK: Gaussian
    
    override public func render() {
        #if !os(tvOS) && !targetEnvironment(simulator)
        customRenderActive = style == .gaussian
        #endif
        super.render()
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        #if !os(tvOS) && !targetEnvironment(simulator)
        return gaussianBlur(texture, with: commandBuffer)
        #else
        return nil
        #endif
    }
    
    #if !os(tvOS) && !targetEnvironment(simulator)
    func gaussianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if #available(macOS 10.13, *) {
            guard let blurTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: PixelKit.main.render.bits, on: PixelKit.main.render.metalDevice, write: true) else {
                PixelKit.main.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
                return nil
            }
            let gaussianBlurKernel = MPSImageGaussianBlur(device: PixelKit.main.render.metalDevice, sigma: Float(relRadius))
            gaussianBlurKernel.edgeMode = extend.mps!
            gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: blurTexture)
            return blurTexture
        } else {
            return nil
        }
    }
    #endif
    
}

public extension NODEOut {
    
    func pixBlur(_ radius: CGFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":blur:"
        blurPix.input = self as? PIX & NODEOut
        blurPix.radius = radius
        return blurPix
    }
    
    func pixZoomBlur(_ radius: CGFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":zoom-blur:"
        blurPix.style = .zoom
        blurPix.quality = .epic
        blurPix.input = self as? PIX & NODEOut
        blurPix.radius = radius
        return blurPix
    }
    
    func pixBloom(radius: CGFloat, amount: CGFloat) -> CrossPIX {
        let pix = self as? PIX & NODEOut
        let bloomPix = (pix!.pixBlur(radius) + pix!) / 2
        return pixCross(pix!, bloomPix, at: amount)
    }
    
}
