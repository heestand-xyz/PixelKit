//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class CirclePIX: PIXGenerator {
    
//    var kind: PIX.Kind = .circle
    
    override open var shader: String { return "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    public var radius: LiveFloat = sqrt(0.75) / 4
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var edgeRadius: LiveFloat = 0.0
    public var color: Color = .white { didSet { setNeedsRender() } }
    public var edgeColor: Color = .gray { didSet { setNeedsRender() } }
    public var bgColor: Color = .black { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case radius; case position; case edgeRadius; case color; case edgeColor; case bgColor
//    }
    
    override var liveValues: [LiveValue] {
        return [radius, edgeRadius]
    }
    
    open override var uniforms: [CGFloat] {
        var vals = [radius.pxv, position.x, position.y, edgeRadius.pxv]
        vals.append(contentsOf: color.list)
        vals.append(contentsOf: edgeColor.list)
        vals.append(contentsOf: bgColor.list)
        return vals
    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        radius = try container.decode(CGFloat.self, forKey: .radius)
//        position = try container.decode(CGPoint.self, forKey: .position)
////        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
//        color = try container.decode(Color.self, forKey: .color)
//        edgeColor = try container.decode(Color.self, forKey: .edgeColor)
//        bgColor = try container.decode(Color.self, forKey: .bgColor)
//        setNeedsRender()
//    }
//
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
////        try container.encode(radius, forKey: .radius)
//        try container.encode(position, forKey: .position)
////        try container.encode(edgeRadius, forKey: .edgeRadius)
//        try container.encode(color, forKey: .color)
//        try container.encode(edgeColor, forKey: .edgeColor)
//        try container.encode(bgColor, forKey: .bgColor)
//    }
    
}
