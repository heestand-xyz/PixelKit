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
