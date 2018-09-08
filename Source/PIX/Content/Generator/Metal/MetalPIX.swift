//
//  MetalGeneratorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class MetalGeneratorPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .metalGenerator
    
    public struct MetalUniform: Codable {
        let name: String
        let value: CGFloat
    }
    
    public var shaderCode: String
    
    public var metalUniforms: [MetalUniform] = [] { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case metalUniforms
    }
    override var uniforms: [CGFloat] {
        return metalUniforms.map({ metalUniform -> CGFloat in
            return metalUniform.value
        })
    }
    
    public init(res: Res, shaderCode: String) {
        self.shaderCode = shaderCode
        super.init(res: res)
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128, shaderCode: "") // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metalUniforms, forKey: .metalUniforms)
    }
    
}
