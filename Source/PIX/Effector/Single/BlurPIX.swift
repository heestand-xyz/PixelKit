//
//  BlurPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-02.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

public class BlurPIX: PIXSingleEffector, CustomRenderDelegate {
    
    public enum BlurType: Int {
        case guassian = 0
        case box = 1
        case angle = 2
        case zoom = 3
        case random = 4
    }
    public var type: BlurType = .guassian { didSet { setNeedsRender() } }
    public var radius: Double = 10 { didSet { setNeedsRender() } }
    public enum BlurQuality: Int {
        case low = 4
        case mid = 8
        case high = 16
        case extreme = 32
    }
    public var quality: BlurQuality = .mid { didSet { setNeedsRender() } }
    public var angle: Double = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    override var shaderUniforms: [Double] {
        return [Double(type.rawValue), radius, Double(quality.rawValue), angle, Double(position.x), Double(position.y)]
    }
    
    public init() {
        super.init(shader: "blur")
        sampleMode = .clampToEdge
        customRenderDelegate = self
    }
    
    override func setNeedsRender() {
        customRenderActive = type == .guassian
        super.setNeedsRender()
    }
    
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        return guassianBlur(texture, with: commandBuffer)
    }
    
    func guassianBlur(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: HxPxE.main.bitMode.pixelFormat, width: texture.width, height: texture.height, mipmapped: true) // CHECK mipmapped
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
