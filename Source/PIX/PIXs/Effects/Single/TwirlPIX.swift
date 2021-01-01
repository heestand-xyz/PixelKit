//
//  TwirlPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-11.
//  Open Source - MIT License
//


import RenderKit

public class TwirlPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    public var strength: CGFloat = CGFloat(2.0, min: 0.0, max: 4.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [strength]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Twirl", typeName: "pix-effect-single-twirl")
        extend = .mirror
    }
    
}

public extension NODEOut {
    
    func _twirl(_ strength: CGFloat) -> TwirlPIX {
        let twirlPix = TwirlPIX()
        twirlPix.name = ":twirl:"
        twirlPix.input = self as? PIX & NODEOut
        twirlPix.strength = strength
        return twirlPix
    }
    
}
