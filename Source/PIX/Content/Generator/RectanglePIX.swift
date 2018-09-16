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
    
    override open var shader: String { return "contentGeneratorRectanglePIX" }
    
    public var size: CGSize = CGSize(width: sqrt(0.75) / 2, height: sqrt(0.75) / 2) { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var bgColor: UIColor = .black { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case size; case position; case color; case bgColor
    }
    override var uniforms: [CGFloat] {
        var vals = [size.width, size.height, position.x, position.y]
        vals.append(contentsOf: PIX.Color(color).list)
        vals.append(contentsOf: PIX.Color(bgColor).list)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = try container.decode(CGSize.self, forKey: .size)
        position = try container.decode(CGPoint.self, forKey: .position)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        bgColor = try container.decode(PIX.Color.self, forKey: .bgColor).ui
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encode(position, forKey: .position)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(PIX.Color(bgColor), forKey: .bgColor)
    }
    
}
