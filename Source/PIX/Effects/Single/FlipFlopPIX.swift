//
//  FlipFlopPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics


public extension PIXOut {
    
    func flipX() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.inPix = self as? PIX & PIXOut
        flipFlopPix.flip = .x
        return flipFlopPix
    }
    
    func flipY() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.inPix = self as? PIX & PIXOut
        flipFlopPix.flip = .y
        return flipFlopPix
    }
    
    func flopLeft() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.inPix = self as? PIX & PIXOut
        flipFlopPix.flop = .left
        return flipFlopPix
    }
    
    func flopRight() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.inPix = self as? PIX & PIXOut
        flipFlopPix.flop = .right
        return flipFlopPix
    }
    
}


public class FlipFlopPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .flipFlop
    
    override open var shader: String { return "effectSingleFlipFlopPIX" }
        
    public enum Flip: String, Codable {
        case x
        case y
        case xy
        var index: Int {
            switch self {
            case .x: return 1
            case .y: return 2
            case .xy: return 3
            }
        }
    }
    
    public enum Flop: String, Codable {
        case left
        case right
        var index: Int {
            switch self {
            case .left: return 1
            case .right: return 2
            }
        }
    }
    
    public var flip: Flip? = nil { didSet { setNeedsRender() } }
    public var flop: Flop? = nil { didSet { applyRes { self.setNeedsRender() } } }
    enum CodingKeys: String, CodingKey {
        case flip; case flop
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(flip?.index ?? 0), CGFloat(flop?.index ?? 0)]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flip = try container.decode(Flip.self, forKey: .flip)
        flop = try container.decode(Flop.self, forKey: .flop)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(flip, forKey: .flip)
        try container.encode(flop, forKey: .flop)
    }
    
}
