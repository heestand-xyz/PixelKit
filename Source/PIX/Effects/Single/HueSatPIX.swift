//
//  HueSatPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-04.
//  Open Source - MIT License
//
import CoreGraphics

public class HueSatPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleHueSatPIX" }
    
    // MARK: - Public Properties

    public var hue: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var saturation: CGFloat = 1.0 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum LevelsCodingKeys: String, CodingKey {
//        case hue; case saturation
//    }
    
    open override var uniforms: [CGFloat] {
        return [hue, saturation, 1]
    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: LevelsCodingKeys.self)
//        hue = try container.decode(CGFloat.self, forKey: .hue)
//        saturation = try container.decode(CGFloat.self, forKey: .saturation)
//        setNeedsRender()
//    }
//
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: LevelsCodingKeys.self)
//        try container.encode(hue, forKey: .hue)
//        try container.encode(saturation, forKey: .saturation)
//    }
    
}

public extension PIXOut {
    
    func _hue(_ hue: CGFloat) -> HueSatPIX {
        let hueSaturationPix = HueSatPIX()
        hueSaturationPix.name = "hue:hueSaturation"
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.hue = hue
        return hueSaturationPix
    }
    
    func _saturation(_ saturation: CGFloat) -> HueSatPIX {
        let hueSaturationPix = HueSatPIX()
        hueSaturationPix.name = "saturation:hueSaturation"
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.saturation = saturation
        return hueSaturationPix
    }
    
    func _monochrome() -> HueSatPIX {
        let hueSaturationPix = HueSatPIX()
        hueSaturationPix.name = "monochrome:hueSaturation"
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.saturation = 0.0
        return hueSaturationPix
    }
    
}
