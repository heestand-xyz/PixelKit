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

public class BlurPIX: PIXSingleEffect, CustomRenderDelegate {
    
    override open var shaderName: String { return "effectSingleBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum BlurStyle: String, CaseIterable {
        case regular
        #if !os(tvOS) && !targetEnvironment(simulator)
        case gaussian
        #endif
        case box
        case angle
        case zoom
        case random
        var index: Int {
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
    }
    
    public var style: BlurStyle = .regular { didSet { setNeedsRender() } }
    /// radius is relative. default at 0.5
    ///
    /// 1.0 at 4K is max, tho at lower resolutions you can go beyond 1.0
    public var radius: CGFloat = 0.5
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0.0
    public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [radius, angle, position]
    }
    
    var relRadius: CGFloat {
        let radius = self.radius
        let relRes: Resolution = ._4K
        let res: Resolution = renderResolution
        let relHeight = res.height / relRes.height
        let relRadius = radius * relHeight //min(radius * relHeight, 1.0)
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius //radius * 32 * 10
    }
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    override open var shaderNeedsAspect: Bool { return true }
    
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
    
    override public func setNeedsRender() {
        #if !os(tvOS) && !targetEnvironment(simulator)
        customRenderActive = style == .gaussian
        #endif
        super.setNeedsRender()
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
    
    func _blur(_ radius: CGFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":blur:"
        blurPix.input = self as? PIX & NODEOut
        blurPix.radius = radius
        return blurPix
    }
    
    func _zoomBlur(_ radius: CGFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":zoom-blur:"
        blurPix.style = .zoom
        blurPix.quality = .epic
        blurPix.input = self as? PIX & NODEOut
        blurPix.radius = radius
        return blurPix
    }
    
    func _bloom(radius: CGFloat, amount: CGFloat) -> CrossPIX {
        let pix = self as? PIX & NODEOut
        let bloomPix = (pix!._blur(radius) + pix!) / 2
        return cross(pix!, bloomPix, at: amount)
    }
    
}
