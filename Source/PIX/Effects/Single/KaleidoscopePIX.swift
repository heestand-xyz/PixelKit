//
//  KaleidoscopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

public class KaleidoscopePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    public var divisions: LiveInt = 12
    public var mirror: LiveBool = true
    public var rotation: LiveFloat = 0
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [divisions, mirror, rotation, position]
    }
    
//    enum KaleidoscopeCodingKeys: String, CodingKey {
//        case divisions; case mirror; case rotation; case position
//    }
    
//    open override var uniforms: [CGFloat] {
//        return [CGFloat(divisions), mirror ? 1 : 0, rotation, position.x, position.y]
//    }
    
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
