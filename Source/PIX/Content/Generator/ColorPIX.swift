//
//  ColorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class ColorPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .color
    
    override var shader: String { return "contentGeneratorColorPIX" }
    
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    enum ColorCodingKeys: String, CodingKey {
        case color; case premultiply
    }
    override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: PIX.Color(color).list)
        vals.append(premultiply ? 1 : 0)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: ColorCodingKeys.self)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ColorCodingKeys.self)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(premultiply, forKey: .premultiply)
    }
    
}
