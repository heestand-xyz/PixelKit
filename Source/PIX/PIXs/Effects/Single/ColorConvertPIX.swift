//
//  ColorConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-24.
//

import Foundation
import CoreGraphics
import RenderKit

final public class ColorConvertPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleColorConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum Direction: String, Enumable {
        case rgbToHsv = "RGB to HSV"
        case hsvToRgb = "HSV to RGB"
        public var index: Int {
            switch self {
            case .rgbToHsv: return 0
            case .hsvToRgb: return 1
            }
        }
        public var names: [String] {
            Self.allCases.map(\.rawValue)
        }
    }
    @LiveEnum(name: "Direction") public var direction: Direction = .rgbToHsv

    public enum Filter: String, Enumable {
        case all = "All"
        case first = "First"
        case second = "Second"
        case third = "Third"
        public var index: Int {
            switch self {
            case .all: return 0
            case .first: return 1
            case .second: return 2
            case .third: return 3
            }
        }
        public var names: [String] {
            Self.allCases.map(\.rawValue)
        }
    }
    /// Filter
    ///
    /// RGB to HSV - First is Hue, Second is Saturation, Third is Value
    ///
    /// HSV to RGB - First is Red, Second is Green, Third is Blue
    @LiveEnum(name: "Filter") public var filter: Filter = .all
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_direction, _filter]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(direction.index), CGFloat(filter.index)]
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
        colorConvertPix.direction = .rgbToHsv
        return colorConvertPix
    }
    
    func pixRgbToHue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToHue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.direction = .rgbToHsv
        colorConvertPix.filter = .first
        return colorConvertPix
    }
    
    func pixRgbToSaturation() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToSaturation:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.direction = .rgbToHsv
        colorConvertPix.filter = .second
        return colorConvertPix
    }
    
    func pixRgbToValue() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "rgbToValue:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.direction = .rgbToHsv
        colorConvertPix.filter = .third
        return colorConvertPix
    }
    
    func pixRsvToRgb() -> ColorConvertPIX {
        let colorConvertPix = ColorConvertPIX()
        colorConvertPix.name = "hsvToRgb:colorConvert"
        colorConvertPix.input = self as? PIX & NODEOut
        colorConvertPix.direction = .hsvToRgb
        return colorConvertPix
    }
    
}
