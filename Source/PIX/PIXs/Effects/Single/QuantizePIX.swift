//
//  QuantizePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class QuantizePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleQuantizePIX" }
    
    // MARK: - Public Properties
    
    public var fraction: CGFloat = 0.125
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [fraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Quantize", typeName: "pix-effect-single-quantize")
    }
    
}

public extension NODEOut {
    
    func _quantize(_ fraction: CGFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.name = ":quantize:"
        quantizePix.input = self as? PIX & NODEOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}
