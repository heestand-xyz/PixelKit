//
//  BlurPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-02.
//  Open Source - MIT License
//

import MetalPerformanceShaders
//#if canImport(SwiftUI)
//import SwiftUI
//#endif

//#if canImport(SwiftUI)
//@available(iOS 13.0.0, *)
//public struct BlurUIPIX: View, UIPIX {
//    public let pix: PIX
//    let blurPix: BlurPIX
//    let inUiPix: UIPIX
//    public var body: some View {
//        PIXRepView(pix: pix)
//    }
//    public init(_ uiPix: () -> (UIPIX)) {
//        blurPix = BlurPIX()
//        blurPix.style = .box
//        pix = blurPix
//        inUiPix = uiPix()
//        blurPix.inPix = inUiPix.pix as? (PIX & PIXOut)
//    }
//    public func radius(_ bind: Binding<CGFloat>) -> BlurUIPIX {
//        blurPix.radius = LiveFloat({ bind.wrappedValue })
//        return self
//    }
//}
//#endif

public class BlurPIX: PIXSingleEffect, PixelCustomRenderDelegate, PIXAuto {
    
    override open var shader: String { return "effectSingleBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum BlurStyle: String, CaseIterable {
        case guassian
        case box
        case angle
        case zoom
        case random
        var index: Int {
            switch self {
            case .guassian: return 0
            case .box: return 1
            case .angle: return 2
            case .zoom: return 3
            case .random: return 4
            }
        }
    }
    
    public var style: BlurStyle = .guassian { didSet { setNeedsRender() } }
    /// radius is relative. default at 0.5
    ///
    /// 1.0 at 4K is max, tho at lower resolutions you can go beyond 1.0
    public var radius: LiveFloat = LiveFloat(0.5, limit: true)
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: LiveFloat = LiveFloat(0.0, min: -0.5, max: 0.5)
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, angle, position]
    }
    
    var relRadius: CGFloat {
        let radius = self.radius.uniform
        let relRes: PIX.Res = ._4K
        let res: PIX.Res = resolution
        let relHeight = res.height.cg / relRes.height.cg
        let relRadius = radius * relHeight //min(radius * relHeight, 1.0)
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius //radius.uniform * 32 * 10
    }
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle.uniform, position.x.uniform, position.y.uniform]
    }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    public required init() {
        super.init()
        extend = .hold
        customRenderDelegate = self
        name = "blur"
    }
    
    // MARK: Guassian
    
    override public func setNeedsRender() {
        customRenderActive = style == .guassian
        super.setNeedsRender()
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        return guassianBlur(texture, with: commandBuffer)
    }
    
    func guassianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if #available(OSX 10.13, *) {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelKit.bits.mtl, width: texture.width, height: texture.height, mipmapped: true) // CHECK mipmapped
            descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
            guard let blurTexture = pixelKit.metalDevice.makeTexture(descriptor: descriptor) else {
                pixelKit.log(pix: self, .error, .generator, "Guassian Blur: Make texture faild.")
                return nil
            }
            let gaussianBlurKernel = MPSImageGaussianBlur(device: pixelKit.metalDevice, sigma: Float(relRadius))
            gaussianBlurKernel.edgeMode = extend.mps!
            gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: blurTexture)
            return blurTexture
        } else {
            return nil
        }
    }
    
}

public extension PIXOut {
    
    func _blur(_ radius: LiveFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":blur:"
        blurPix.inPix = self as? PIX & PIXOut
        blurPix.radius = radius
        return blurPix
    }
    
    func _zoomBlur(_ radius: LiveFloat) -> BlurPIX {
        let blurPix = BlurPIX()
        blurPix.name = ":zoom-blur:"
        blurPix.style = .zoom
        blurPix.quality = .epic
        blurPix.inPix = self as? PIX & PIXOut
        blurPix.radius = radius
        return blurPix
    }
    
    func _bloom(radius: LiveFloat, amount: LiveFloat) -> CrossPIX {
        let pix = self as? PIX & PIXOut
        let bloomPix = (pix!._blur(radius) + pix!) / 2
        return cross(pix!, bloomPix, at: amount)
    }
    
}
