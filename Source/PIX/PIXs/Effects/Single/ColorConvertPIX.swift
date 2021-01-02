//
//  ColorConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-24.
//

import CoreGraphics

import RenderKit

public class ColorConvertPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleColorConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum ColorConvertWay: String, CaseIterable {
        case rgbToHsv = "RGB to HSV"
        case hsvToRgb = "HSV to RGB"
        var index: Int {
            switch self {
            case .rgbToHsv: return 0
            case .hsvToRgb: return 1
            }
        }
    }
    public var ccWay: ColorConvertWay = .rgbToHsv { didSet { setNeedsRender() } }
    
    public enum ColorConvertIndex: Int, CaseIterable {
        case all = 0
        case first = 1
        case second = 2
        case third = 3
    }
    /// Color Convert Index
    ///
    /// RGB to HSV - First is Hue, Second is Saturation, Third is Value
    ///
    /// HSV to RGB - First is Red, Second is Green, Third is Blue
    public var ccIndex: ColorConvertIndex = .all { didSet { setNeedsRender() } }
    
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] { [CGFloat(ccWay.index), CGFloat(ccIndex.rawValue)] }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Color Convert", typeName: "pix-effect-single-color-convert")
    }
    
}

public extension NODEOut {
    
    func _rgbToHsv() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHsv:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        return colorConvertPix
    }
    
    func _rgbToHue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .first
        return colorConvertPix
    }
    
    func _rgbToSaturation() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToSaturation:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .second
        return colorConvertPix
    }
    
    func _rgbToValue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToValue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .rgbToHsv
        colorConvertPix.ccIndex = .third
        return colorConvertPix
    }
    
    func _hsvToRgb() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "hsvToRgb:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.ccWay = .hsvToRgb
        return colorConvertPix
    }
    
}
