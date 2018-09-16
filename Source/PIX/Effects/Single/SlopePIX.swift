//
//  SlopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func slope(_ amplitude: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.inPix = self as? PIX & PIXOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}

public class SlopePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .slope
    
    override open var shader: String { return "effectSingleSlopePIX" }
    
    public var amplitude: CGFloat = 1.0 { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case amplitude
    }
    override var uniforms: [CGFloat] {
        return [amplitude]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amplitude = try container.decode(CGFloat.self, forKey: .amplitude)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amplitude, forKey: .amplitude)
    }
    
}
