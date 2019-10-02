//
//  SlopePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

import LiveValues

public class SlopePIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    public var amplitude: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [amplitude]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "slope"
    }
    
}

public extension PIXOut {
    
    func _slope(_ amplitude: LiveFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.inPix = self as? PIX & PIXOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}
