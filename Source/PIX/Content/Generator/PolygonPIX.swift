//
//  PolygonPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PolygonPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .polygon
    
    override var shader: String { return "polygonPIX" }
    override var shaderNeedsAspect: Bool { return true }
    
    public var radius: CGFloat = 0.25 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var rotation: CGFloat = 0 { didSet { setNeedsRender() } }
    public var vertexCount: Int = 6 { didSet { setNeedsRender() } }
    public var color: UIColor = .white { didSet { setNeedsRender() } }
    public var bgColor: UIColor = .black { didSet { setNeedsRender() } }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    enum CircleCodingKeys: String, CodingKey {
        case radius; case position; case rotation; case vertexCount; case color; case bgColor; case premultiply
    }
    override var shaderUniforms: [CGFloat] {
        var uniforms = [radius, position.x, position.y, rotation, CGFloat(vertexCount)]
        uniforms.append(contentsOf: PIX.Color(color).list)
        uniforms.append(contentsOf: PIX.Color(bgColor).list)
        uniforms.append(premultiply ? 1 : 0)
        return uniforms
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CircleCodingKeys.self)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        vertexCount = try container.decode(Int.self, forKey: .vertexCount)
        color = try container.decode(PIX.Color.self, forKey: .color).ui
        bgColor = try container.decode(PIX.Color.self, forKey: .bgColor).ui
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CircleCodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(vertexCount, forKey: .vertexCount)
        try container.encode(PIX.Color(color), forKey: .color)
        try container.encode(PIX.Color(bgColor), forKey: .bgColor)
        try container.encode(premultiply, forKey: .premultiply)
    }
    
}
