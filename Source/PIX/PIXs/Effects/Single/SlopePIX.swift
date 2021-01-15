//
//  SlopePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class SlopePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    @Live public var amplitude: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_amplitude]
    }
    
    override public var values: [Floatable] {
        return [amplitude]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Slope", typeName: "pix-effect-single-slope")
    }
    
}

public extension NODEOut {
    
    func _slope(_ amplitude: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.input = self as? PIX & NODEOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}
