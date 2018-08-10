//
//  EdgePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class EdgePIX: PIXSingleEffect, PIXable {
    
    let kind: PIX.Kind = .edge
    
    override var shader: String { return "edgePIX" }
    
    public var strength: CGFloat = 4 { didSet { setNeedsRender() } }
    public var distance: CGFloat = 1 { didSet { setNeedsRender() } }
    enum EdgeCodingKeys: String, CodingKey {
        case strength; case distance
    }
    override var shaderUniforms: [CGFloat] {
        return [strength, distance]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        strength = try container.decode(CGFloat.self, forKey: .strength)
        distance = try container.decode(CGFloat.self, forKey: .distance)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(strength, forKey: .strength)
        try container.encode(distance, forKey: .distance)
    }
    
}
