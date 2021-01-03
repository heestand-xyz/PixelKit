//
//  ColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-04.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

@available(*, deprecated, renamed: "ColorShiftPIX")
public typealias HueSaturationPIX = ColorShiftPIX

public class ColorShiftPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleColorShiftPIX" }
    
    // MARK: - Public Properties

    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 1.0
    public var tintColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [hue, saturation, tintColor]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Color Shift", typeName: "pix-effect-single-color-shift")
    }
    
}

public extension NODEOut {
    
    func _tint(_ tintColor: PixelColor) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "tint:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.tintColor = tintColor
        return colorShiftPix
    }
    
    func _hue(_ hue: CGFloat) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "hue:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.hue = hue
        return colorShiftPix
    }
    
    func _saturation(_ saturation: CGFloat) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "saturation:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.saturation = saturation
        return colorShiftPix
    }
    
    func _monochrome(_ tintColor: PixelColor = .white) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "monochrome:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.saturation = 0.0
        colorShiftPix.tintColor = tintColor
        return colorShiftPix
    }
    
}
