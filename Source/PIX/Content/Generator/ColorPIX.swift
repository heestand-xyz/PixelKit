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
    
    override open var shader: String { return "contentGeneratorColorPIX" }
    
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case color
    }
    open override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: PIX.Color(color).list)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(PIX.Color(color), forKey: .color)
    }
    
}
