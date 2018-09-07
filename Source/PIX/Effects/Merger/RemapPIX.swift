//
//  RemapPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class RemapPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .remap
    
    override var shader: String { return "effectMergerRemapPIX" }
    
    public var distance: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var origin: CGPoint = CGPoint(x: 0.5, y: 0.5) { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case distance; case origin
    }
    override var uniforms: [CGFloat] {
        return []
    }
    
    public override init() {
        super.init()
        extend = .hold
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distance = try container.decode(CGFloat.self, forKey: .distance)
        origin = try container.decode(CGPoint.self, forKey: .origin)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distance, forKey: .distance)
        try container.encode(origin, forKey: .origin)
    }
    
    
}
