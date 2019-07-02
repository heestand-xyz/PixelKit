//
//  TwirlPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-11.
//  Open Source - MIT License
//

public class TwirlPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    public var strength: LiveFloat = 2.0
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [strength]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        extend = .mirror
        name = "twirl"
    }
    
}

public extension PIXOut {
    
    func _twirl(_ strength: LiveFloat) -> TwirlPIX {
        let twirlPix = TwirlPIX()
        twirlPix.name = ":twirl:"
        twirlPix.inPix = self as? PIX & PIXOut
        twirlPix.strength = strength
        return twirlPix
    }
    
}
