//
//  ChromaKeyPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public extension PIXOut {
    
    func chromaKey(_ color: UIColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.inPix = self as? PIX & PIXOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}

public class ChromaKeyPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .chromaKey
    
    override var shader: String { return "effectSingleChromaKeyPIX" }
    
    public var keyColor: UIColor = .green { didSet { setNeedsRender() } }
    public var range: CGFloat = 0.1 { didSet { setNeedsRender() } }
    public var softness: CGFloat = 0.1 { didSet { setNeedsRender() } }
    public var edgeDesaturation: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    enum ChromaKeyCodingKeys: String, CodingKey {
        case keyColor; case range; case softness; case edgeDesaturation; case premultiply
    }
    override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: PIX.Color(keyColor).list)
        vals.append(contentsOf: [range, softness, edgeDesaturation, premultiply ? 1 : 0])
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: ChromaKeyCodingKeys.self)
        keyColor = try container.decode(Color.self, forKey: .keyColor).ui
        range = try container.decode(CGFloat.self, forKey: .range)
        softness = try container.decode(CGFloat.self, forKey: .softness)
        edgeDesaturation = try container.decode(CGFloat.self, forKey: .edgeDesaturation)
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChromaKeyCodingKeys.self)
        try container.encode(PIX.Color(keyColor), forKey: .keyColor)
        try container.encode(range, forKey: .range)
        try container.encode(softness, forKey: .softness)
        try container.encode(edgeDesaturation, forKey: .edgeDesaturation)
        try container.encode(premultiply, forKey: .premultiply)
    }
    
}
