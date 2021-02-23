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
    
    public enum Direction: String, CaseIterable, Floatable {
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
    @Live(name: "Direction") public var direction: Direction = .rgbToHsv

    public enum Filter: Int, CaseIterable, Floatable {
        case all = 0
        case first = 1
        case second = 2
        case third = 3
        public var floats: [CGFloat] { [CGFloat(rawValue)] }
        public init(floats: [CGFloat]) {
            self = Self.allCases.first(where: { $0.rawValue == Int(floats.first ?? 0.0) }) ?? Self.allCases.first!
        }
    }
    /// Filter
    ///
    /// RGB to HSV - First is Hue, Second is Saturation, Third is Value
    ///
    /// HSV to RGB - First is Red, Second is Green, Third is Blue
    @Live(name: "Filter") public var filter: Filter = .all
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_direction, _filter]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(direction.index), CGFloat(filter.rawValue)]
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
