//
//  ColorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class ColorPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .color
    
    override open var shader: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Public Properties
    
    public var color: Color = .white { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case color
    }
    open override var uniforms: [CGFloat] {
        return color.list
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(Color.self, forKey: .color)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
    }
    
}

//public extension PIX {
//    
//    func __color(_ color: PIX.Color, res: PIX.Res) -> ColorPIX {
//        let colorPix = ColorPIX(res: res)
//        colorPix.name = ":color:"
//        colorPix.color = color
//        return colorPix
//    }
//
//}
