//
//  QuantizePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class QuantizePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .quantize
    
    override var shader: String { return "quantizePIX" }
    
    public var fraction: CGFloat = 0.125 { didSet { setNeedsRender() } }
    enum QuantizeCodingKeys: String, CodingKey {
        case fraction
    }
    override var shaderUniforms: [CGFloat] {
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
