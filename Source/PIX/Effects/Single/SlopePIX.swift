//
//  SlopePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func slope(_ amplitide: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.inPix = self as? PIX & PIXOut
        slopePix.amplitide = amplitide
        return slopePix
    }
    
}

public class SlopePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .slope
    
    override var shader: String { return "effectSingleSlopePIX" }
    
    public var amplitide: CGFloat = 1.0 { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case amplitide
    }
    override var uniforms: [CGFloat] {
        return [amplitide]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amplitide = try container.decode(CGFloat.self, forKey: .amplitide)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amplitide, forKey: .amplitide)
    }
    
}
