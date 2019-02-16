//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//
import CoreGraphics//x

public class CirclePIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    public var radius: LiveFloat = sqrt(0.75) / 4
    public var position: LivePoint = .zero
    public var edgeRadius: LiveFloat = 0.0
    public var color: LiveColor = .white
    public var edgeColor: LiveColor = .gray
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, position, edgeRadius, color, edgeColor, bgColor]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case radius; case position; case edgeRadius; case color; case edgeColor; case bgColor
//    }
    
//    open override var uniforms: [CGFloat] {
//        var vals: [CGFloat] = []
//        vals.append(radius.uniform)
//        vals.append(contentsOf: position.uniformList)
//        vals.append(edgeRadius.uniform)
//        vals.append(contentsOf: color.uniformList)
//        vals.append(contentsOf: edgeColor.uniformList)
//        vals.append(contentsOf: bgColor.uniformList)
//        return vals
//    }
    
//     MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        radius = try container.decode(CGFloat.self, forKey: .radius)
//        position = try container.decode(CGPoint.self, forKey: .position)
////        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
//        color = try container.decode(Color.self, forKey: .color)
//        edgeLiveColor = try container.decode(Color.self, forKey: .edgeColor)
//        bgLiveColor = try container.decode(Color.self, forKey: .bgColor)
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
