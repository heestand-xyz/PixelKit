//
//  SlopePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class SlopePIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    public var amplitude: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [amplitude]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Slope", typeName: "pix-effect-single-slope")
    }
    
}

public extension NODEOut {
    
    func _slope(_ amplitude: LiveFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.input = self as? PIX & NODEOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}
