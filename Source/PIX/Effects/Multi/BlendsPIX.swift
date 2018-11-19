//
//  BlendsPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-14.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class BlendsPIX: PIXMultiEffect, PIXofaKind {
    
    let kind: PIX.Kind = .blends
    
    override open var shader: String { return "effectMultiBlendsPIX" }
    
    // MARK: - Public Properties
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum BlendsCodingKeys: String, CodingKey {
        case blendingMode
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index)]
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: BlendsCodingKeys.self)
        blendingMode = try container.decode(BlendingMode.self, forKey: .blendingMode)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BlendsCodingKeys.self)
        try container.encode(blendingMode, forKey: .blendingMode)
    }
    
}
