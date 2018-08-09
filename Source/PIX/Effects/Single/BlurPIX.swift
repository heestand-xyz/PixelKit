//
//  BlurPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-02.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

public class BlurPIX: PIXSingleEffect, PIXable, CustomRenderDelegate {
    
    let kind: HxPxE.PIXKind = .blur
    
    override var shader: String { return "blurPIX" }
    
    public enum BlurType: Int, Codable {
        case guassian = 0
        case box = 1
        case angle = 2
        case zoom = 3
        case random = 4
    }
    
    public enum BlurQuality: Int, Codable {
        case low = 4
        case mid = 8
        case high = 16
        case extreme = 32
    }
    
    public var type: BlurType = .guassian { didSet { setNeedsRender() } }
    public var radius: CGFloat = 10 { didSet { setNeedsRender() } }
    public var quality: BlurQuality = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    enum BlurCodingKeys: String, CodingKey {
        case type; case radius; case quality; case angle; case position
    }
    override var shaderUniforms: [CGFloat] {
        return [CGFloat(type.rawValue), radius, CGFloat(quality.rawValue), angle, CGFloat(position.x), CGFloat(position.y)]
    }
    
    override public init() {
        super.init()
        sampleMode = .clampToEdge
        customRenderDelegate = self
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: BlurCodingKeys.self)
        type = try container.decode(BlurType.self, forKey: .type)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        quality = try container.decode(BlurQuality.self, forKey: .quality)
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
        try container.encode(type, forKey: .type)
        try container.encode(radius, forKey: .radius)
        try container.encode(quality, forKey: .quality)
        try container.encode(angle, forKey: .angle)
        try container.encode(position, forKey: .position)
    }
    
    // MARK: Guassian
    
    override func setNeedsRender() {
        customRenderActive = type == .guassian
        super.setNeedsRender()
    }
    
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        return guassianBlur(texture, with: commandBuffer)
    }
    
    func guassianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: HxPxE.main.colorBits.mtl, width: texture.width, height: texture.height, mipmapped: true) // CHECK mipmapped
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
        guard let blurTexture = HxPxE.main.metalDevice!.makeTexture(descriptor: descriptor) else {
            print("HxPxE ERROR:", "Render:", "BlurPIX:", "Make texture faild.")
            return nil
        }
        let gaussianBlurKernel = MPSImageGaussianBlur(device: HxPxE.main.metalDevice!, sigma: Float(radius))
        switch sampleMode {
        case .clampToZero:
            gaussianBlurKernel.edgeMode = .zero
        default:
            gaussianBlurKernel.edgeMode = .clamp
        }
        gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: blurTexture)
        return blurTexture
    }
    
}
