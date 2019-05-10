//
//  QuantizePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

public class QuantizePIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleQuantizePIX" }
    
    // MARK: - Public Properties
    
    public var fraction: LiveFloat = 0.125
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [fraction]
    }
    
}

public extension PIXOut {
    
    func _quantize(_ fraction: LiveFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.name = ":quantize:"
        quantizePix.inPix = self as? PIX & PIXOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}
