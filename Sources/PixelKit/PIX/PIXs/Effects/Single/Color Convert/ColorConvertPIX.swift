//
//  ColorConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-24.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import MetalKit

final public class ColorConvertPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = ColorConvertPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleColorConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum Conversion: String, Enumable {
        case rgbToHsv
        case hsvToRgb
        case linearToSRGB
        case sRGBToLinear
        public var index: Int {
            switch self {
            case .rgbToHsv: return 0
            case .hsvToRgb: return 1
            case .linearToSRGB: return 2
            case .sRGBToLinear: return 3
            }
        }
        public var name: String {
            switch self {
            case .rgbToHsv: return "RGB to HSV"
            case .hsvToRgb: return "HSV to RGB"
            case .linearToSRGB: return "Linear to sRGB"
            case .sRGBToLinear: return "sRGB to Linear"
            }
        }
        public var typeName: String { rawValue }
    }
    @available(*, deprecated, renamed: "conversion")
    public var direction: Conversion {
        get { conversion }
        set { conversion = newValue }
    }
    @LiveEnum("conversion") public var conversion: Conversion = .rgbToHsv

    public enum Channel: String, Enumable {
        case all
        case first
        case second
        case third
        public var index: Int {
            switch self {
            case .all: return 0
            case .first: return 1
            case .second: return 2
            case .third: return 3
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .all: return "All"
            case .first: return "First"
            case .second: return "Second"
            case .third: return "Third"
            }
        }
    }
    /// Channel
    ///
    /// RGB to HSV - First is Hue, Second is Saturation, Third is Value
    ///
    /// HSV to RGB - First is Red, Second is Green, Third is Blue
    @LiveEnum("channel") public var channel: Channel = .all
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_conversion, _channel]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(conversion.index), CGFloat(channel.index)]
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
        
        customRenderActive = [.linearToSRGB, .sRGBToLinear].contains(conversion)
        _conversion.didSetValue = { [weak self] in
            guard let self = self else { return }
            self.customRenderActive = [.linearToSRGB, .sRGBToLinear].contains(self.conversion)
        }
        
        customRenderDelegate = self
        
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        conversion = model.conversion
        channel = model.channel
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.conversion = conversion
        model.channel = channel
        
        super.liveUpdateModelDone()
    }
}

extension ColorConvertPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        let ciFilterName: String
        switch conversion {
        case .linearToSRGB:
            ciFilterName = "CILinearToSRGBToneCurve"
        case .sRGBToLinear:
            ciFilterName = "CISRGBToneCurveToLinear"
        default:
            return nil
        }
        
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        let parameters: [String : Any]? = [
            kCIInputImageKey : ciImage
        ]
            
        guard let filter: CIFilter = CIFilter(name: ciFilterName, parameters: parameters) else { return nil }
        guard let finalImage: CIImage = filter.outputImage else { return nil }
        
        do {
            let finalTexture: MTLTexture = try Texture.makeTexture(from: finalImage,
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

public extension NODEOut {
    
    func pixRgbToHsv() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHsv:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.conversion = .rgbToHsv
        return colorConvertPix
    }
    
    func pixRgbToHue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.conversion = .rgbToHsv
        colorConvertPix.channel = .first
        return colorConvertPix
    }
    
    func pixRgbToSaturation() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToSaturation:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.conversion = .rgbToHsv
        colorConvertPix.channel = .second
        return colorConvertPix
    }
    
    func pixRgbToValue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToValue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.conversion = .rgbToHsv
        colorConvertPix.channel = .third
        return colorConvertPix
    }
    
    func pixRsvToRgb() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "hsvToRgb:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.conversion = .hsvToRgb
        return colorConvertPix
    }
    
}
