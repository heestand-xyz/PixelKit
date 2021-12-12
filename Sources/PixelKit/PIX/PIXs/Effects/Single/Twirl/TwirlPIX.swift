//
//  TwirlPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-11.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class TwirlPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("strength", range: 0.0...5.0, increment: 1.0) public var strength: CGFloat = 2.0
    
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
