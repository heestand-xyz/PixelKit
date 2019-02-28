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
    
    public var metalUniforms: [MetalUniform] { didSet { setNeedsRender() } }
    
    public var code: String { didSet { setNeedsRender() } }
    public var isRawCode: Bool = false
    var metalCode: String? {
        if isRawCode { return code }
        do {
          return try pixels.embedMetalCode(uniforms: metalUniforms, code: code, fileName: metalFileName)
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
        self.code = code
        super.init(res: res)
    }
    
}

public extension MetalPIX {
    
    static func _uv(res: Res) -> MetalPIX {
        let metalPix = MetalPIX(res: res, code:
            """
            pix = float4(u, v, 0.0, 1.0);
            """
        )
        metalPix.name = "uv:metal"
        return metalPix
    }
    
}
