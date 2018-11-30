//
//  BlurPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-02.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x
import MetalKit
import MetalPerformanceShaders

public class BlurPIX: PIXSingleEffect, PixelsCustomRenderDelegate {
    
    override open var shader: String { return "effectSingleBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum Style: String, Codable {
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
    
    public var style: Style = .guassian { didSet { setNeedsRender() } }
    /// radius is relative. default at 0.5
    ///
    /// 1.0 at 4K is max, tho at lower resolutions you can go beyond 1.0
    public var radius: LiveFloat = 0.5
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: LiveFloat = 0.0
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, angle, position]
    }
    
//    enum BlurCodingKeys: String, CodingKey {
//        case style; case radius; case quality; case angle; case position
//    }
    
    var relRadius: CGFloat {
        let radius = self.radius.uniform
        let relRes: PIX.Res = ._4K
        let res: PIX.Res = resolution ?? relRes
        let relHeight = res.height / relRes.height
        let relRadius = min(radius * relHeight, 1.0)
        print(relRadius)
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius //radius.uniform * 32 * 10
    }
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle.uniform, position.x.uniform, position.y.uniform]
    }
    
    override public init() {
        super.init()
        extend = .hold
        customRenderDelegate = self
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: BlurCodingKeys.self)
//        style = try container.decode(Style.self, forKey: .style)
//        radius = try container.decode(CGFloat.self, forKey: .radius)
//        quality = try container.decode(SampleQualityMode.self, forKey: .quality)
//        angle = try container.decode(CGFloat.self, forKey: .angle)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        setNeedsRender()
////        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
////        let id = UUID(uuidString: try topContainer.decode(String.self, forKey: .id))! // CHECK BANG
////        super.init(id: id)
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
////        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: BlurCodingKeys.self)
//        try container.encode(style, forKey: .style)
//        try container.encode(radius, forKey: .radius)
//        try container.encode(quality, forKey: .quality)
//        try container.encode(angle, forKey: .angle)
//        try container.encode(position, forKey: .position)
//    }
    
    // MARK: Guassian
    
    override public func setNeedsRender() {
        customRenderActive = style == .guassian
        super.setNeedsRender()
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        return guassianBlur(texture, with: commandBuffer)
    }
    
    func guassianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixels.bits.mtl, width: texture.width, height: texture.height, mipmapped: true) // CHECK mipmapped
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
        guard let blurTexture = pixels.metalDevice.makeTexture(descriptor: descriptor) else {
            pixels.log(pix: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let gaussianBlurKernel = MPSImageGaussianBlur(device: pixels.metalDevice, sigma: Float(relRadius))
        gaussianBlurKernel.edgeMode = extend.mps
        gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: blurTexture)
        return blurTexture
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
    
}
