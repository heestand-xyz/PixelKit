//
//  ColorCorrectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-10-05.
//

import Foundation
import RenderKit
import Resolution
import MetalKit
import PixelColor

final public class ColorCorrectPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = ColorCorrectPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: Properties
    
    @LiveColor("whitePoint") public var whitePoint: PixelColor = .white
    @LiveFloat("vibrance") public var vibrance: CGFloat = 0.0
    /// Cold is `-1.0`, neutral is `0.0` and warm is `1.0`.
    @LiveFloat("temperature", range: -1.0...1.0) public var temperature: CGFloat = 0.0

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_whitePoint, _vibrance, _temperature]
    }
    
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
    
    // MARK: Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        whitePoint = model.whitePoint
        vibrance = model.vibrance
        temperature = model.temperature
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.whitePoint = whitePoint
        model.vibrance = vibrance
        model.temperature = temperature
        
        super.liveUpdateModelDone()
    }
}

extension ColorCorrectPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        /// White Point
        
        let whitePointParameters: [String : Any]? = [
            kCIInputImageKey : ciImage,
            "inputColor": whitePoint.ciColor,
        ]
            
        guard let whitePointFilter: CIFilter = CIFilter(name: "CIWhitePointAdjust", parameters: whitePointParameters) else { return nil }
        guard let whitePointImage: CIImage = whitePointFilter.outputImage else { return nil }
        
        /// Vibrance
        
        let vibranceParameters: [String : Any]? = [
            kCIInputImageKey : whitePointImage,
            "inputAmount": NSNumber(value: vibrance),
        ]
            
        guard let vibranceFilter: CIFilter = CIFilter(name: "CIVibrance", parameters: vibranceParameters) else { return nil }
        guard let vibranceImage: CIImage = vibranceFilter.outputImage else { return nil }
        
        /// Temperature
        
        let normal: CGFloat = temperature / 2 + 0.5
        let neutral: CGFloat = 2_000 + normal * 8_000
        let targetNeutral: CGFloat = 2_000 + (1.0 - normal) * 8_000
        
        let temperatureParameters: [String : Any]? = [
            kCIInputImageKey : vibranceImage,
            "inputNeutral": CIVector(x: neutral),
            "inputTargetNeutral": CIVector(x: targetNeutral),
        ]
            
        guard let temperatureFilter: CIFilter = CIFilter(name: "CITemperatureAndTint", parameters: temperatureParameters) else { return nil }
        guard let temperatureImage: CIImage = temperatureFilter.outputImage else { return nil }
        
        /// Final
        
        do {
            let finalTexture: MTLTexture = try Texture.makeTexture(from: temperatureImage,
                                                                   at: texture.resolution.size,
                                                                   colorSpace: PixelKit.main.render.colorSpace,
                                                                   bits: PixelKit.main.render.bits,
                                                                   with: commandBuffer,
                                                                   on: PixelKit.main.render.metalDevice)
            return finalTexture
        } catch {
            PixelKit.main.logger.log(node: self, .error, .resource, "CI Filter Failed", e: error)
            return nil
        }
        
    }
    
}
