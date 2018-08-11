//
//  TwirlPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-11.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class TwirlPIX: PIXSingleEffect, PIXable {
    
    let kind: PIX.Kind = .twirl
    
    override var shader: String { return "twirlPIX" }
    
    public var strength: CGFloat = 1 { didSet { setNeedsRender() } }
    enum TwirlCodingKeys: String, CodingKey {
        case strength
    }
    override var shaderUniforms: [CGFloat] {
        return [strength]
    }
    
    public override init() {
        super.init()
        extendMode = .mirrorRepeat
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: TwirlCodingKeys.self)
        strength = try container.decode(CGFloat.self, forKey: .strength)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TwirlCodingKeys.self)
        try container.encode(strength, forKey: .strength)
    }
    
}
