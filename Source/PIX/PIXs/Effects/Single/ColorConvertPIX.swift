//
//  ColorConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-24.
//

import CoreGraphics

import RenderKit

final public class ColorConvertPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleColorConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum ColorConvertWay: String, CaseIterable, Floatable {
        case rgbToHsv = "RGB to HSV"
        case hsvToRgb = "HSV to RGB"
        var index: Int {
            switch self {
            case .rgbToHsv: return 0
            case .hsvToRgb: return 1
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
        public init(floats: [CGFloat]) {
            self = Self.allCases.first(where: { $0.index == Int(floats.first ?? 0.0) }) ?? Self.allCases.first!
        }
    }
    @Live public var ccWay: ColorConvertWay = .rgbToHsv

    public enum ColorConvertIndex: Int, CaseIterable, Floatable {
        case all = 0
        case first = 1
        case second = 2
        case third = 3
        public var floats: [CGFloat] { [CGFloat(rawValue)] }
        public init(floats: [CGFloat]) {
            self = Self.allCases.first(where: { $0.rawValue == Int(floats.first ?? 0.0) }) ?? Self.allCases.first!
        }
    }
    /// Color Convert Index
    ///
    /// RGB to HSV - First is Hue, Second is Saturation, Third is Value
    ///
    /// HSV to RGB - First is Red, Second is Green, Third is Blue
    @Live public var ccIndex: ColorConvertIndex = .all
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_ccWay, _ccIndex]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(ccWay.index), CGFloat(ccIndex.rawValue)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Color Convert", typeName: "pix-effect-single-color-convert")
    }
    
}

public extension NODEOut {
    
    func pixRgbToHsv() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHsv:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        return colorConvertPix
    }
    
    func pixRgbToHue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .first
        return colorConvertPix
    }
    
    func pixRgbToSaturation() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToSaturation:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .second
        return colorConvertPix
    }
    
    func pixRgbToValue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToValue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .third
        return colorConvertPix
    }
    
    func pixRsvToRgb() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "hsvToRgb:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .hsvToRgb
        return colorConvertPix
    }
    
}
