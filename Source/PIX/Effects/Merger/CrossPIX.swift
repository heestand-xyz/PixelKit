//
//  CrossPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-21.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class CrossPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .cross
    
    override open var shader: String { return "effectMergerCrossPIX" }
    
    // MARK: - Public Properties
    
    public var fraction: CGFloat = 0.5 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case fraction
    }
    
    open override var uniforms: [CGFloat] {
        return [fraction]
    }
        
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fraction = try container.decode(CGFloat.self, forKey: .fraction)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fraction, forKey: .fraction)
    }
    
}
