//
//  RectanglePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class RectanglePIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .rectangle
    
    override var shader: String { return "contentGeneratorRectanglePIX" }
    override var shaderNeedsAspect: Bool { return true }
    
    public var size: CGSize = CGSize(width: 0.5, height: 0.5) { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var bgColor: UIColor = .black { didSet { setNeedsRender() } }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    enum RectangleCodingKeys: String, CodingKey {
        case size; case position; case color; case bgColor; case premultiply
    }
    override var uniforms: [CGFloat] {
        var vals = [size.width, size.height, position.x, position.y]
        vals.append(contentsOf: PIX.Color(color).list)
        vals.append(contentsOf: PIX.Color(bgColor).list)
        vals.append(premultiply ? 1 : 0)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: RectangleCodingKeys.self)
        size = try container.decode(CGSize.self, forKey: .size)
        position = try container.decode(CGPoint.self, forKey: .position)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        bgColor = try container.decode(PIX.Color.self, forKey: .bgColor).ui
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RectangleCodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encode(position, forKey: .position)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(PIX.Color(bgColor), forKey: .bgColor)
        try container.encode(premultiply, forKey: .premultiply)
    }
    
}
