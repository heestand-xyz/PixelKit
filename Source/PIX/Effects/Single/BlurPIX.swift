//
//  BlurPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-02.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

public class BlurPIX: PIXSingleEffect, PIXofaKind, CustomRenderDelegate {
    
    let kind: PIX.Kind = .blur
    
    override var shader: String { return "effectSingleBlurPIX" }
    
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
    
    public enum Quality: String, Codable {
        case low
        case mid
        case high
        case extreme
        var value: Int {
            switch self {
            case .low: return 4
            case .mid: return 8
            case .high: return 16
            case .extreme: return 32
            }
        }
    }
    
    public var style: Style = .guassian { didSet { setNeedsRender() } }
    public var radius: CGFloat = 10 { didSet { setNeedsRender() } }
    public var quality: Quality = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    enum BlurCodingKeys: String, CodingKey {
        case style; case radius; case quality; case angle; case position
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius, CGFloat(quality.value), angle, CGFloat(position.x), CGFloat(position.y)]
    }
    
    override public init() {
        super.init()
        extend = .clampToEdge
        customRenderDelegate = self
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: BlurCodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        quality = try container.decode(Quality.self, forKey: .quality)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        position = try container.decode(CGPoint.self, forKey: .position)
        setNeedsRender()
//        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
//        let id = UUID(uuidString: try topContainer.decode(String.self, forKey: .id))! // CHECK BANG
//        super.init(id: id)
    }
    
    override public func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: BlurCodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encode(radius, forKey: .radius)
        try container.encode(quality, forKey: .quality)
        try container.encode(angle, forKey: .angle)
        try container.encode(position, forKey: .position)
    }
    
    // MARK: Guassian
    
    override func setNeedsRender() {
        customRenderActive = style == .guassian
        super.setNeedsRender()
    }
    
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        return guassianBlur(texture, with: commandBuffer)
    }
    
    func guassianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixels.colorBits.mtl, width: texture.width, height: texture.height, mipmapped: true) // CHECK mipmapped
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
        guard let blurTexture = pixels.metalDevice!.makeTexture(descriptor: descriptor) else {
            pixels.log(pix: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let gaussianBlurKernel = MPSImageGaussianBlur(device: pixels.metalDevice!, sigma: Float(radius))
        switch extend {
        case .clampToZero:
            gaussianBlurKernel.edgeMode = .zero
        default:
            gaussianBlurKernel.edgeMode = .clamp
        }
        gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: blurTexture)
        return blurTexture
    }
    
}
