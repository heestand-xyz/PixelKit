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

final public class ColorConvertPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleColorConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum Conversion: String, Enumable {
        case rgbToHsv
        case hsvToRgb
        public var index: Int {
            switch self {
            case .rgbToHsv: return 0
            case .hsvToRgb: return 1
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .rgbToHsv: return "RGB to HSV"
            case .hsvToRgb: return "HSV to RGB"
            }
        }
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
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Color Convert", typeName: "pix-effect-single-color-convert")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
