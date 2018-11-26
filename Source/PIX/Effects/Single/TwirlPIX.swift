//
//  TwirlPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-11.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class TwirlPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    public var strength: CGFloat = 1 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum TwirlCodingKeys: String, CodingKey {
//        case strength
//    }
    
    open override var uniforms: [CGFloat] {
        return [strength]
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        extend = .mirror
    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: TwirlCodingKeys.self)
//        strength = try container.decode(CGFloat.self, forKey: .strength)
//        setNeedsRender()
//    }
//
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: TwirlCodingKeys.self)
//        try container.encode(strength, forKey: .strength)
//    }
    
}

public extension PIXOut {
    
    func _twirl(_ strength: CGFloat) -> TwirlPIX {
        let twirlPix = TwirlPIX()
        twirlPix.name = ":twirl:"
        twirlPix.inPix = self as? PIX & PIXOut
        twirlPix.strength = strength
        return twirlPix
    }
    
}
