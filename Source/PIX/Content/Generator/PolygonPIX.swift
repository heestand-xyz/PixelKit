//
//  PolygonPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//
import CoreGraphics//x

public class PolygonPIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var radius: LiveFloat = 0.25
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var vertexCount: LiveInt = 6
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
   
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, position, rotation, vertexCount, color, bgColor]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case radius; case position; case rotation; case vertexCount; case color; case bgColor
//    }
    
//    open override var uniforms: [CGFloat] {
//        var vals: [CGFloat] = []
//        vals.append(radius.uniform)
//        vals.append(contentsOf: position.uniformList)
//        vals.append(rotation.uniform)
//        vals.append(CGFloat(vertexCount.uniform))
//        vals.append(contentsOf: color.uniformList)
//        vals.append(contentsOf: bgColor.uniformList)
//        return vals
//    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        radius = try container.decode(CGFloat.self, forKey: .radius)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        rotation = try container.decode(CGFloat.self, forKey: .rotation)
//        vertexCount = try container.decode(Int.self, forKey: .vertexCount)
//        color = try container.decode(Color.self, forKey: .color)
//        bgLiveColor = try container.decode(Color.self, forKey: .bgColor)
//        setNeedsRender()
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(radius, forKey: .radius)
//        try container.encode(position, forKey: .position)
//        try container.encode(rotation, forKey: .rotation)
//        try container.encode(vertexCount, forKey: .vertexCount)
//        try container.encode(color, forKey: .color)
//        try container.encode(bgColor, forKey: .bgColor)
//    }
    
}
