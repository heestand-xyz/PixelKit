//
//  ResPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-03.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class ResPIX: PIXSingleEffect, PIXofaKind {

    let kind: PIX.Kind = .res
    
    override var shader: String { return "effectSingleResPIX" }
    override var shaderNeedsAspect: Bool { return true }
    
    public var res: Res { didSet { applyRes { self.setNeedsRender() } } }
    public var resMultiplier: CGFloat = 1 { didSet { applyRes { self.setNeedsRender() } } }
    public var inheritInRes: Bool = false { didSet { applyRes { self.setNeedsRender() } } } // CHECK upstream resolution exists
    public var fillMode: FillMode = .aspectFit { didSet { setNeedsRender() } }
    enum ResCodingKeys: String, CodingKey {
        case resMultiplier; case inheritInRes; case fillMode
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(fillMode.index)]
    }
    
    public init(res: Res) {
        self.res = res
        super.init()
    }

    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: ResCodingKeys.self)
        resMultiplier = try container.decode(CGFloat.self, forKey: .resMultiplier)
        inheritInRes = try container.decode(Bool.self, forKey: .inheritInRes)
        fillMode = try container.decode(FillMode.self, forKey: .fillMode)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ResCodingKeys.self)
        try container.encode(resMultiplier, forKey: .resMultiplier)
        try container.encode(inheritInRes, forKey: .inheritInRes)
        try container.encode(fillMode, forKey: .fillMode)
    }

}
