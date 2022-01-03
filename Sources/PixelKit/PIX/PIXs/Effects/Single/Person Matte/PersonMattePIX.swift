////
////  PersonMattePIX.swift
////  PixelKit
////
////  Created by Anton Heestand on 2021-10-04.
////
//
//import Foundation
//import RenderKit
//import Resolution
//import Vision
//
//@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
//final public class PersonMattePIX: PIXSingleEffect, PIXViewable {
//
//    override public var shaderName: String { return "nilPIX" }
//
//    // MARK: - Life Cycle -
//
//    public required init() {
//        super.init(name: "Person Matte", typeName: "pix-effect-single-person-matte")
//        setup()
//    }
//
//    required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//        setup()
//    }
//
//    // MARK: Setup
//
//    private func setup() {
//        customRenderActive = true
//        customRenderDelegate = self
//    }
//
//}
//
//@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
//extension PersonMattePIX: CustomRenderDelegate {
//
//    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//
//        guard let pixelBuffer: CVPixelBuffer = try? Texture.pixelBuffer(from: texture, at: texture.resolution.size, colorSpace: PixelKit.main.render.colorSpace, bits: PixelKit.main.render.bits) else { return nil }
//
//        let request = VNGeneratePersonSegmentationRequest()
//        
//        do {
//
//            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
//
//            guard let observation: VNPixelBufferObservation = request.results?.first as? VNPixelBufferObservation else { return nil }
//
//            let finalTexture: MTLTexture = try Texture.makeTextureFromCache(from: observation.pixelBuffer, bits: PixelKit.main.render.bits, in: PixelKit.main.render.textureCache)
//
//            return finalTexture
//
//        } catch {
//            PixelKit.main.render.logger.log(node: self, .error, .resource, "Optical Flow Failed", e: error)
//            return nil
//        }
//
//    }
//
//}
