//
//  EdgePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class EdgePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    public var strength: CGFloat = 4 { didSet { setNeedsRender() } }
    public var distance: CGFloat = 1 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum EdgeCodingKeys: String, CodingKey {
//        case strength; case distance
//    }
    
    open override var uniforms: [CGFloat] {
        return [strength, distance]
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
//        strength = try container.decode(CGFloat.self, forKey: .strength)
//        distance = try container.decode(CGFloat.self, forKey: .distance)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
//        try container.encode(strength, forKey: .strength)
//        try container.encode(distance, forKey: .distance)
//    }
    
}

public extension PIXOut {
    
    func _edge() -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.inPix = self as? PIX & PIXOut
        return edgePix
    }
    
}
