//
//  KaleidoscopePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

public class KaleidoscopePIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    public var divisions: LiveInt = 12
    public var mirror: LiveBool = true
    public var rotation: LiveFloat = 0
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [divisions, mirror, rotation, position]
    }
    
    public override required init() {
        super.init()
        extend = .mirror
    }
    
}

public extension PIXOut {
    
    func _kaleidoscope(divisions: LiveInt = 12, mirror: LiveBool = true) -> KaleidoscopePIX {
        let kaleidoscopePix = KaleidoscopePIX()
        kaleidoscopePix.name = ":kaleidoscope:"
        kaleidoscopePix.inPix = self as? PIX & PIXOut
        kaleidoscopePix.divisions = divisions
        kaleidoscopePix.mirror = mirror
        return kaleidoscopePix
    }
    
}
