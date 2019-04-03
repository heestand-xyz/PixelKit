//
//  HueSatPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-04.
//  Open Source - MIT License
//

public class HueSatPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleHueSatPIX" }
    
    // MARK: - Public Properties

    public var hue: LiveFloat = 0.0
    public var sat: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [hue, sat]
    }
    
}

public extension PIXOut {
    
    func _hue(_ hue: LiveFloat) -> HueSatPIX {
        let hueSatPix = HueSatPIX()
        hueSatPix.name = "hue:hueSaturation"
        hueSatPix.inPix = self as? PIX & PIXOut
        hueSatPix.hue = hue
        return hueSatPix
    }
    
    func _saturation(_ sat: LiveFloat) -> HueSatPIX {
        let hueSatPix = HueSatPIX()
        hueSatPix.name = "saturation:hueSaturation"
        hueSatPix.inPix = self as? PIX & PIXOut
        hueSatPix.sat = sat
        return hueSatPix
    }
    
    func _monochrome() -> HueSatPIX {
        let hueSatPix = HueSatPIX()
        hueSatPix.name = "monochrome:hueSaturation"
        hueSatPix.inPix = self as? PIX & PIXOut
        hueSatPix.sat = 0.0
        return hueSatPix
    }
    
}
