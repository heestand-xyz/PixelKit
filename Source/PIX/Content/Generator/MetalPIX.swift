//
//  MetalGeneratorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

/// Metal Shader (Generator)
///
/// Example:
/// ~~~~swift
/// let metalPix = MetalPIX(res: ._1080p, code:
///     """
///     pix = float4(u, v, 0.0, 1.0);
///     """
/// )
/// ~~~~
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
    
    // MARK: - Life Cycle
    
    public init(res: Res, uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        metalEmbedCode = code
        super.init(res: res)
    }
    
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
