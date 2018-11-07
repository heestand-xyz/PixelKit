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
    
    // MARK: - Public Properties
    
    public var size: CGSize = CGSize(width: sqrt(0.75) / 2, height: sqrt(0.75) / 2) { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var color: Color = .white { didSet { setNeedsRender() } }
    public var bgColor: Color = .black { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case size; case position; case color; case bgColor
    }
    
    open override var uniforms: [CGFloat] {
        var vals = [size.width, size.height, position.x, position.y]
        vals.append(contentsOf: color.list)
        vals.append(contentsOf: bgColor.list)
        return vals
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = try container.decode(CGSize.self, forKey: .size)
        position = try container.decode(CGPoint.self, forKey: .position)
        color = try container.decode(Color.self, forKey: .color)
        bgColor = try container.decode(Color.self, forKey: .bgColor)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encode(position, forKey: .position)
        try container.encode(color, forKey: .color)
        try container.encode(bgColor, forKey: .bgColor)
    }
    
}
