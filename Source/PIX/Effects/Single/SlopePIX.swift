//
//  SlopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class SlopePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .slope
    
    override open var shader: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    public var amplitude: CGFloat = 1.0 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case amplitude
    }
    
    open override var uniforms: [CGFloat] {
        return [amplitude]
    }
    
    // MARK: - JSON
    
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

public extension PIXOut {
    
    func _slope(_ amplitude: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.inPix = self as? PIX & PIXOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}
