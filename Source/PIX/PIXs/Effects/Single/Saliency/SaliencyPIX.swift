//
//  SaliencyPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-23.
//


import RenderKit
import Resolution
import Vision
import CoreImage

@available(iOS 13.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0, *)
final public class SaliencyPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    override public var shaderName: String { return "contentResourceRedToWhitePIX" }
    
    override var customResolution: Resolution? { .square(68) }
    
    // MARK: - Public Properties
    
    public enum SaliencyStyle: String, Enumable {
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
        public var index: Int { revision }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .attention: return "Attention"
            case .objectness: return "Objectness"
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
    @LiveEnum("style") public var style: SaliencyStyle = .attention
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Saliency", typeName: "pix-effect-single-saliency")
        customRenderDelegate = self
        customRenderActive = true
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
                let size: CGSize = customResolution!.size
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

@available(macOS 10.15, *)
public extension NODEOut {
    
    func pixRange(style: SaliencyPIX.SaliencyStyle) -> SaliencyPIX {
        let saliencyPix = SaliencyPIX()
        saliencyPix.name = ":saliency:"
        saliencyPix.input = self as? PIX & NODEOut
        saliencyPix.style = style
        return saliencyPix
    }
    
}

