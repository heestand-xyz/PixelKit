//
//  MetalGeneratorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

public class MetalPIX: PIXGenerator, PIXMetal {
    
    override open var shader: String { return "contentGeneratorMetalPIX" }
    
    // MARK: - Private Properties

    let metalFileName = "ContentGeneratorMetalPIX.metal"
    
    var metalUniforms: [MetalUniform]
    
    var metalEmbedCode: String
    var metalCode: String? {
        do {
          return try pixels.embedMetalCode(uniforms: metalUniforms, code: metalEmbedCode, fileName: metalFileName)
        } catch {
            pixels.log(pix: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return metalUniforms.map({ uniform -> LiveFloat in return uniform.value })
    }
    
//    enum CodingKeys: String, CodingKey {
//        case metalUniforms
//    }
    
//    open override var uniforms: [CGFloat] {
//        return metalUniforms.map({ metalUniform -> CGFloat in
//            return metalUniform.value
//        })
//    }
    
    // MARK: - Life Cycle
    
    public init(res: Res, uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        metalEmbedCode = code
        super.init(res: res)
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128, code: "") // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
//        setNeedsRender()
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(metalUniforms, forKey: .metalUniforms)
//    }
    
}

public extension MetalPIX {
    
    public static func _uv(res: Res) -> MetalPIX {
        let metalPix = MetalPIX(res: res, code:
            """
            pix = float4(u, v, 0.0, 1.0);
            """
        )
        metalPix.name = "uv:metal"
        return metalPix
    }
    
}
