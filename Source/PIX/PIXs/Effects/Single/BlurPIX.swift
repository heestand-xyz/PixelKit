//
//  BlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-02.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics
import MetalKit
#if !os(tvOS) && !targetEnvironment(simulator)
// MPS does not support the iOS simulator.
import MetalPerformanceShaders
#endif

final public class BlurPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum BlurStyle: String, Enumable {
        case regular
        #if !os(tvOS) && !targetEnvironment(simulator)
        case gaussian
        #endif
        case box
        case angle
        case zoom
        case random
        public var index: Int {
            switch self {
            case .regular:
                #if !os(tvOS) && !targetEnvironment(simulator)
                return 0
                #else
                return 1
                #endif
            #if !os(tvOS) && !targetEnvironment(simulator)
            case .gaussian: return 0
            #endif
            case .box: return 1
            case .angle: return 2
            case .zoom: return 3
            case .random: return 4
            }
        }
        public var name: String {
            switch self {
            case .regular:
                return "Regular"
            #if !os(tvOS) && !targetEnvironment(simulator)
            case .gaussian: return "Guassian"
            #endif
            case .box: return "Box"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            case .random: return "Random"
            }
        }
    }
    
    @LiveEnum("style") public var style: BlurStyle = .regular
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
        let res: Resolution = finalResolution ?? ._1024
        let relHeight = res.height / relRes.height
        let relRadius = radius * relHeight
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius
    }
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Life Cycle
    
    public required init() {
        #if !os(tvOS) && !targetEnvironment(simulator)
        style = .gaussian
        #else
        style = .box
        #endif
        super.init(name: "Blur", typeName: "pix-effect-single-blur")
        extend = .hold
        customRenderDelegate = self
    }
    
    // MARK: Guassian
    
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
        if #available(OSX 10.13, *) {
            guard let blurTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: pixelKit.render.bits, on: pixelKit.render.metalDevice, write: true) else {
                pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
                return nil
            }
            let gaussianBlurKernel = MPSImageGaussianBlur(device: pixelKit.render.metalDevice, sigma: Float(relRadius))
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
