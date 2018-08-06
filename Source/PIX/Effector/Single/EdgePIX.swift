//
//  EdgePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class EdgePIX: PIXSingleEffector, PIXable {
    
    let kind: HxPxE.PIXKind = .edge
    
    override var shader: String { return "edge" }
    
    public var strength: Double = 4 { didSet { setNeedsRender() } }
    public var distance: Double = 1 { didSet { setNeedsRender() } }
    enum EdgeCodingKeys: String, CodingKey {
        case strength; case distance
    }
    override var shaderUniforms: [Double] {
        return [strength, distance]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        strength = try container.decode(Double.self, forKey: .strength)
        distance = try container.decode(Double.self, forKey: .distance)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(strength, forKey: .strength)
        try container.encode(distance, forKey: .distance)
    }
    
}
