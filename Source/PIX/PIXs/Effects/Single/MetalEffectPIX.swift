//
//  MetalEffectPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

import LiveValues
import Metal

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
    
    public var metalUniforms: [MetalUniform] { didSet { bakeFrag() } }
    
    public var code: String { didSet { bakeFrag() } }
    public var isRawCode: Bool = false
    var metalCode: String? {
        if isRawCode { return code }
        console = nil
        do {
            return try pixelKit.embedMetalCode(uniforms: metalUniforms, code: code, fileName: metalFileName)
        } catch {
            pixelKit.log(pix: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    public var console: String?
    public var consoleCallback: ((String) -> ())?
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return metalUniforms.map({ uniform -> LiveFloat in return uniform.value })
    }
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init()
        name = "metalEffect"
    }
    
    required init() {
        metalUniforms = []
        code = ""
        super.init()
    }
    
    func bakeFrag() {
        console = nil
        do {
            let frag = try pixelKit.makeMetalFrag(shader, from: self)
            try makePipeline(with: frag)
        } catch {
            switch error {
            case PixelKit.ShaderError.metalError(let codeError, let errorFrag):
                pixelKit.log(pix: self, .error, nil, "Metal code failed.", e: codeError)
                console = codeError.localizedDescription
                consoleCallback?(console!)
                do {
                    try makePipeline(with: errorFrag)
                } catch {
                    pixelKit.log(pix: self, .fatal, nil, "Metal fail failed.", e: error)
                }
            default:
                pixelKit.log(pix: self, .fatal, nil, "Metal bake failed.", e: error)
            }
        }
    }
    
    func makePipeline(with frag: MTLFunction) throws {
        let vtx: MTLFunction? = customVertexShaderName != nil ? try pixelKit.makeVertexShader(customVertexShaderName!, with: customMetalLibrary) : nil
        pipeline = try pixelKit.makeShaderPipeline(frag, with: vtx)
        setNeedsRender()
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
