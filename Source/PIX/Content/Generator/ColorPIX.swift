//
//  ColorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class ColorPIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Public Properties
    
    public var color: LiveColor = .white { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [color]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case color
//    }

//    open override var uniforms: [CGFloat] {
//        return color.list
//    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        color = try container.decode(Color.self, forKey: .color)
//        setNeedsRender()
//    }
//
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(color, forKey: .color)
//    }
    
}

//public extension PIX {
//    
//    func __color(_ color: LiveColor, res: PIX.Res) -> ColorPIX {
//        let colorPix = ColorPIX(res: res)
//        colorPix.name = ":color:"
//        colorPix.color = color
//        return colorPix
//    }
//
//}
