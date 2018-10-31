//
//  PolygonPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class PolygonPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .polygon
    
    override open var shader: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var radius: CGFloat = 0.25 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var rotation: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var vertexCount: Int = 6 { didSet { setNeedsRender() } }
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var bgColor: UIColor = .black { didSet { setNeedsRender() } }
   
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case radius; case position; case rotation; case vertexCount; case color; case bgColor
    }
    
    open override var uniforms: [CGFloat] {
        var vals = [radius, position.x, position.y, rotation, CGFloat(vertexCount)]
        vals.append(contentsOf: PIX.Color(color).list)
        vals.append(contentsOf: PIX.Color(bgColor).list)
        return vals
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        vertexCount = try container.decode(Int.self, forKey: .vertexCount)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        bgColor = try container.decode(PIX.Color.self, forKey: .bgColor).ui
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(vertexCount, forKey: .vertexCount)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(PIX.Color(bgColor), forKey: .bgColor)
    }
    
}
