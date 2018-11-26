//
//  KaleidoscopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class KaleidoscopePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    public var divisions: Int = 12 { didSet { setNeedsRender() } }
    public var mirror: Bool = true { didSet { setNeedsRender() } }
    public var rotation: CGFloat = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum KaleidoscopeCodingKeys: String, CodingKey {
        case divisions; case mirror; case rotation; case position
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(divisions), mirror ? 1 : 0, rotation, position.x, position.y]
    }
    
    public override required init() {
        super.init()
        extend = .mirror
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: KaleidoscopeCodingKeys.self)
        divisions = try container.decode(Int.self, forKey: .divisions)
        mirror = try container.decode(Bool.self, forKey: .mirror)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        position = try container.decode(CGPoint.self, forKey: .position)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KaleidoscopeCodingKeys.self)
        try container.encode(divisions, forKey: .divisions)
        try container.encode(mirror, forKey: .mirror)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(position, forKey: .position)
    }
    
}

public extension PIXOut {
    
    func _kaleidoscope(divisions: Int = 12, mirror: Bool = true) -> KaleidoscopePIX {
        let kaleidoscopePix = KaleidoscopePIX()
        kaleidoscopePix.name = ":kaleidoscope:"
        kaleidoscopePix.inPix = self as? PIX & PIXOut
        kaleidoscopePix.divisions = divisions
        kaleidoscopePix.mirror = mirror
        return kaleidoscopePix
    }
    
}
