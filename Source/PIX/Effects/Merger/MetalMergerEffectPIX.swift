//
//  MetalMergerEffectPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

/// Metal Shader (Merger Effect)
///
/// vars: pi, u, v, uv, wA, hA, wuA, hvA, inPixA, wB, hB, wuB, hvB, inPixB
///
/// float4 inPixA = inTexA.sample(s, uv);
///
/// Example:
/// ~~~~swift
/// let metalMergerEffectPix = MetalMergerEffectPIX(code:
///     """
///     pix = pow(inPixA, 1.0 / inPixB);
///     """
/// )
/// metalMergerEffectPix.inPixA = CameraPIX()
/// metalMergerEffectPix.inPixB = ImagePIX("img_name")
/// ~~~~
public class MetalMergerEffectPIX: PIXMergerEffect, PIXMetal {
    
    override open var shader: String { return "effectMergerMetalPIX" }
    
    // MARK: - Private Properties
    
    let metalFileName = "EffectMergerMetalPIX.metal"
    
    public override var shaderNeedsAspect: Bool { return true }
    
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
    
    override public var liveValues: [LiveValue] {
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
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        metalEmbedCode = code
        super.init()
    }
    
    required override init() {
        metalUniforms = []
        metalEmbedCode = ""
        super.init()
    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init(code: "") // CHECK
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
