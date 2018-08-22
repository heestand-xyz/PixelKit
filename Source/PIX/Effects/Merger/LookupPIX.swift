//
//  LookupPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class LookupPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .lookup
    
    override var shader: String { return "effectMergerLookupPIX" }
    
    public enum Axis: String, Codable {
        case x
        case y
    }
    
    public var axis: Axis = .x { didSet { setNeedsRender() } }
    enum LookupCodingKeys: String, CodingKey {
        case axis
    }
    override var uniforms: [CGFloat] {
        return [axis == .x ? 0 : 1]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    
    public override func encode(to encoder: Encoder) throws {}
    
    
}
