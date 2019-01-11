//
//  RectanglePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class RectanglePIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    public var size: LiveSize = LiveSize(w: sqrt(0.75) / 2, h: sqrt(0.75) / 2)
    public var position: LivePoint = .zero
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [size, position, color, bgColor]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case size; case position; case color; case bgColor
//    }
    
//    open override var uniforms: [CGFloat] {
//        var vals: [CGFloat] = []
//        vals.append(contentsOf: size.uniformList)
//        vals.append(contentsOf: position.uniformList)
//        vals.append(contentsOf: color.uniformList)
//        vals.append(contentsOf: bgColor.uniformList)
//        return vals
//    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        size = try container.decode(CGSize.self, forKey: .size)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        color = try container.decode(Color.self, forKey: .color)
//        bgLiveColor = try container.decode(Color.self, forKey: .bgColor)
//        setNeedsRender()
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(size, forKey: .size)
//        try container.encode(position, forKey: .position)
//        try container.encode(color, forKey: .color)
//        try container.encode(bgColor, forKey: .bgColor)
//    }
    
}
