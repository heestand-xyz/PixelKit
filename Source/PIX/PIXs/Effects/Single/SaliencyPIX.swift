//
//  SaliencyPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-23.
//  Copyright © 2020 Hexagons. All rights reserved.
//


import RenderKit
import Vision
import CoreImage

@available(iOS 13.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0, *)
public class SaliencyPIX: PIXSingleEffect, CustomRenderDelegate {
    
    override open var shaderName: String { return "contentResourceRedToWhitePIX" }
    
    override var customResolution: Resolution? { .square(68) }
    
    // MARK: - Public Properties
    
    public enum SaliencyStyle: String, CaseIterable {
        case attention
        case objectness
        var revision: Int {
            switch self {
            case .attention:
                return VNGenerateAttentionBasedSaliencyImageRequestRevision1
            case .objectness:
                return VNGenerateObjectnessBasedSaliencyImageRequestRevision1
            }
        }
        func request() -> VNImageBasedRequest {
            switch self {
            case .attention:
                return VNGenerateAttentionBasedSaliencyImageRequest()
            case .objectness:
                return VNGenerateObjectnessBasedSaliencyImageRequest()
            }
        }
    }
    public var style: SaliencyStyle = .attention { didSet { setNeedsRender() } }
    
    public required init() {
        super.init(name: "Saliency", typeName: "pix-effect-single-saliency")
        customRenderDelegate = self
        customRenderActive = true
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard let cgImage: CGImage = Texture.cgImage(from: texture, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(node: self, .error, .effect, "Texture to image conversion failed.")
            return nil
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request: VNImageBasedRequest = style.request()
        request.revision = style.revision
        do {
            try handler.perform([request])
            guard let result = request.results?.first, let observation = result as? VNSaliencyImageObservation else {
                pixelKit.logger.log(node: self, .error, .effect, "Saliency gave no result.")
                return nil
            }
            let pixelBuffer: CVPixelBuffer = observation.pixelBuffer
            let saliencyTexture: MTLTexture
            if style == .objectness {
                let ciImage: CIImage = Texture.ciImage(from: pixelBuffer)
                let size: CGSize = customResolution!.size.cg
                saliencyTexture = try Texture.makeTexture(from: ciImage, at: size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits, with: commandBuffer, on: pixelKit.render.metalDevice, vFlip: false)
            } else {
                saliencyTexture = try Texture.makeTextureFromCache(from: pixelBuffer, bits: pixelKit.render.bits, in: pixelKit.render.textureCache)
            }
            return saliencyTexture
        } catch {
            pixelKit.logger.log(node: self, .error, .effect, "Saliency failed with error.", e: error)
            return nil
        }
        
    }
    
}
