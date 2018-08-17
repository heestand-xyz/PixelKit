//
//  ThresholdPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-17.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ThresholdPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .threshold
    
    override var shader: String { return "thresholdPIX" }
    
    public var threshold: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var smoothness: CGFloat = 0 { didSet { setNeedsRender() } }
    enum EdgeCodingKeys: String, CodingKey {
        case threshold; case smoothness
    }
    override var shaderUniforms: [CGFloat] {
        return [threshold, smoothness]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
        smoothness = try container.decode(CGFloat.self, forKey: .smoothness)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(smoothness, forKey: .smoothness)
    }
    
}
