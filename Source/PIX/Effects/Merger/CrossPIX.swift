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
    
    override var shader: String { return "effectMergerCrossPIX" }
    
    public var lerp: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var fillMode: FillMode = .aspectFit { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case lerp; case fillMode
    }
    override var uniforms: [CGFloat] {
        return [lerp, CGFloat(fillMode.index)]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lerp = try container.decode(CGFloat.self, forKey: .lerp)
        fillMode = try container.decode(FillMode.self, forKey: .fillMode)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lerp, forKey: .lerp)
    }
    
    
}
