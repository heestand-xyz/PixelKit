//
//  QuantizePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class QuantizePIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleQuantizePIX" }
    
    // MARK: - Public Properties
    
    public var fraction: LiveFloat = LiveFloat(0.125, limit: true)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [fraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Quantize", typeName: "pix-effect-single-quantize")
    }
    
}

public extension NODEOut {
    
    func _quantize(_ fraction: LiveFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.name = ":quantize:"
        quantizePix.input = self as? PIX & NODEOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}
