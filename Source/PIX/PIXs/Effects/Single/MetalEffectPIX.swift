//
//  MetalEffectPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

/// Metal Shader (Effect)
///
/// vars: pi, u, v, uv, w, h, wu, hv, inPix
///
/// Example:
/// ~~~~swift
/// let metalEffectPix = MetalEffectPIX(code:
///     """
///     float gamma = 0.25;
///     pix = pow(inPix, 1.0 / gamma);
///     """
/// )
/// metalEffectPix.inPix = CameraPIX()
/// ~~~~
public class MetalEffectPIX: PIXSingleEffect, PIXMetal {
    
    override open var shader: String { return "effectSingleMetalPIX" }
    
    // MARK: - Private Properties

    let metalFileName = "EffectSingleMetalPIX.metal"
    
    public override var shaderNeedsAspect: Bool { return true }
    
    var metalUniforms: [MetalUniform]
    
    var metalEmbedCode: String
    var metalCode: String? {
        do {
            return try pixelKit.embedMetalCode(uniforms: metalUniforms, code: metalEmbedCode, fileName: metalFileName)
        } catch {
            pixelKit.log(pix: self, .error, .metal, "Metal code could not be generated.", e: error)
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
    
    required init() {
        metalUniforms = []
        metalEmbedCode = ""
        super.init()
    }
    
}


public extension PIXOut {
    
    func _lumaToAlpha() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            float luma = (inPix.r + inPix.g + inPix.b) / 3;
            pix = float4(inPix.r, inPix.r, inPix.r, luma);
            """
        )
        metalEffectPix.name = "lumaToAlpha:metalEffectPix"
        metalEffectPix.inPix = self as? PIX & PIXOut
        return metalEffectPix
    }
    
}
