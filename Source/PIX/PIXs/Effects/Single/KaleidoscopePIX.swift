//
//  KaleidoscopePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class KaleidoscopePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    @Live public var divisions: Int = 12
    @Live public var mirror: Bool = true
    @Live public var rotation: CGFloat = 0.0
    @Live public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_divisions, _mirror, _rotation, _position]
    }
    
    override public var values: [Floatable] {
        [divisions, mirror, rotation, position]
    }
    
    public required init() {
        super.init(name: "Kaleidoscope", typeName: "pix-effect-single-kaleidoscope")
        extend = .mirror
    }
    
}

public extension NODEOut {
    
    func pixKaleidoscope(divisions: Int = 12, mirror: Bool = true) -> KaleidoscopePIX {
        let kaleidoscopePix = KaleidoscopePIX()
        kaleidoscopePix.name = ":kaleidoscope:"
        kaleidoscopePix.input = self as? PIX & NODEOut
        kaleidoscopePix.divisions = divisions
        kaleidoscopePix.mirror = mirror
        return kaleidoscopePix
    }
    
}
