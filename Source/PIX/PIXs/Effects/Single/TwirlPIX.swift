//
//  TwirlPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-11.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class TwirlPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    @Live public var strength: CGFloat = 2.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_strength]
    }
    
    override public var values: [Floatable] {
        return [strength]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Twirl", typeName: "pix-effect-single-twirl")
        extend = .mirror
    }
    
}

public extension NODEOut {
    
    func pixTwirl(_ strength: CGFloat) -> TwirlPIX {
        let twirlPix = TwirlPIX()
        twirlPix.name = ":twirl:"
        twirlPix.input = self as? PIX & NODEOut
        twirlPix.strength = strength
        return twirlPix
    }
    
}
