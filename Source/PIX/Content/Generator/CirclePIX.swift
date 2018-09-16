//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class CirclePIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .circle
    
    override open var shader: String { return "contentGeneratorCirclePIX" }
    
    public var radius: CGFloat = sqrt(0.75) / 4 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var edgeRadius: CGFloat = 0.0 { didSet { setNeedsRender() } } // CHECK radius is not diameter
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var edgeColor: UIColor = .gray { didSet { setNeedsRender() } }
    public var bgColor: UIColor = .black { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case radius; case position; case edgeRadius; case color; case edgeColor; case bgColor
    }
    override var uniforms: [CGFloat] {
        var vals = [radius, position.x, position.y, edgeRadius]
        vals.append(contentsOf: PIX.Color(color).list)
        vals.append(contentsOf: PIX.Color(edgeColor).list)
        vals.append(contentsOf: PIX.Color(bgColor).list)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        edgeColor = try container.decode(PIX.Color.self, forKey: .edgeColor).ui
        bgColor = try container.decode(PIX.Color.self, forKey: .bgColor).ui
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(position, forKey: .position)
        try container.encode(edgeRadius, forKey: .edgeRadius)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(PIX.Color(edgeColor), forKey: .edgeColor)
        try container.encode(PIX.Color(bgColor), forKey: .bgColor)
    }
    
}
