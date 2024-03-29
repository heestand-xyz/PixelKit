//
//  OpticalFlowPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-10-04.
//

import Foundation
import RenderKit
import Resolution
import Vision

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
final public class OpticalFlowPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = OpticalFlowPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
        
    private var lastInputTexture: MTLTexture?
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    public override func destroy() {
        super.destroy()
        lastInputTexture = nil
    }
    
    // MARK: - Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
extension OpticalFlowPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        defer {
            lastInputTexture = texture
        }
        
        guard let lastTexture: MTLTexture = lastInputTexture else { return nil }
        
        guard let pixelBuffer: CVPixelBuffer = try? Texture.pixelBuffer(from: texture, at: texture.resolution.size, colorSpace: PixelKit.main.render.colorSpace, bits: PixelKit.main.render.bits) else { return nil }
        guard let lastPixelBuffer: CVPixelBuffer = try? Texture.pixelBuffer(from: lastTexture, at: texture.resolution.size, colorSpace: PixelKit.main.render.colorSpace, bits: PixelKit.main.render.bits) else { return nil }
        
        let request = VNGenerateOpticalFlowRequest(targetedCVPixelBuffer: pixelBuffer, options: [:])
        
        do {
        
            try VNImageRequestHandler(cvPixelBuffer: lastPixelBuffer, options: [:]).perform([request])
            
            guard let observation: VNPixelBufferObservation = request.results?.first else { return nil }
                        
            let finalTexture: MTLTexture = try Texture.makeTextureViaRawData(from: observation.pixelBuffer, bits: PixelKit.main.render.bits, on: PixelKit.main.render.metalDevice, sourceZero: Float(0.0), sourceOne: Float(1.0), normalize: true, invertGreen: true)
            
            return finalTexture
            
        } catch {
            PixelKit.main.render.logger.log(node: self, .error, .resource, "Optical Flow Failed", e: error)
            return nil
        }
        
    }
    
}
