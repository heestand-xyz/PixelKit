//
//  MetalEffectPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class MetalEffectPIX: PIXSingleEffect, PIXMetal, PIXofaKind {
    
    let kind: PIX.Kind = .metalEffect
    
    let metalFileName = "EffectSingleMetalPIX.metal"
    override var shader: String { return "effectSingleMetalPIX" }
    
    var metalEmbedCode: String
    var metalCode: String? {
        do {
            return try pixels.embedMetalCode(uniforms: metalUniforms, code: metalEmbedCode, fileName: metalFileName)
        } catch {
            pixels.log(pix: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    
    public var metalUniforms: [MetalUniform] = [] { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case metalUniforms
    }
    override var uniforms: [CGFloat] {
        return metalUniforms.map({ metalUniform -> CGFloat in
            return metalUniform.value
        })
    }
    
    public init(code: String) {
        metalEmbedCode = code
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(code: "") // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metalUniforms, forKey: .metalUniforms)
    }
    
}
