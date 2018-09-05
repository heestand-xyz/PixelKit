//
//  QuantizePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func quantize(by fraction: CGFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.inPix = self as? PIX & PIXOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}

public class QuantizePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .quantize
    
    override var shader: String { return "effectSingleQuantizePIX" }
    
    public var fraction: CGFloat = 0.125 { didSet { setNeedsRender() } }
    enum QuantizeCodingKeys: String, CodingKey {
        case fraction
    }
    override var uniforms: [CGFloat] {
        return [fraction]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: QuantizeCodingKeys.self)
        fraction = try container.decode(CGFloat.self, forKey: .fraction)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: QuantizeCodingKeys.self)
        try container.encode(fraction, forKey: .fraction)
    }
    
}
