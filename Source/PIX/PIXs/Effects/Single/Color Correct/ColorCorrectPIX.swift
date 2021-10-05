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
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: Properties
    
    @LiveColor("whitePoint") public var whitePoint: PixelColor = .white
    @LiveFloat("vibrance") public var vibrance: CGFloat = 0.0
    @LiveFloat("temperature", range: -1.0...1.0) public var temperature: CGFloat = 0.0

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_whitePoint, _vibrance, _temperature]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Color Correct", typeName: "pix-effect-single-color-correct")
        setup()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
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