//
//  HueSaturationPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-04.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func hue(_ hue: CGFloat) -> HueSaturationPIX {
        let hueSaturationPix = HueSaturationPIX()
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.hue = hue
        return hueSaturationPix
    }
    
    func saturation(_ saturation: CGFloat) -> HueSaturationPIX {
        let hueSaturationPix = HueSaturationPIX()
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.saturation = saturation
        return hueSaturationPix
    }
    
    func monochrome() -> HueSaturationPIX {
        let hueSaturationPix = HueSaturationPIX()
        hueSaturationPix.inPix = self as? PIX & PIXOut
        hueSaturationPix.saturation = 0.0
        return hueSaturationPix
    }
    
}

public class HueSaturationPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .hueSaturation
    
    override open var shader: String { return "effectSingleHueSaturationPIX" }

    public var hue: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var saturation: CGFloat = 1.0 { didSet { setNeedsRender() } }
    enum LevelsCodingKeys: String, CodingKey {
        case hue; case saturation
    }
    open override var uniforms: [CGFloat] {
        return [hue, saturation, 1]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: LevelsCodingKeys.self)
        hue = try container.decode(CGFloat.self, forKey: .hue)
        saturation = try container.decode(CGFloat.self, forKey: .saturation)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LevelsCodingKeys.self)
        try container.encode(hue, forKey: .hue)
        try container.encode(saturation, forKey: .saturation)
    }
    
}
