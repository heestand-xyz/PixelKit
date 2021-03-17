//
//  MetalEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Metal

/// Metal Shader (Effect)
///
/// vars: pi, u, v, uv, w, h, wu, hv, input
///
/// Example:
/// ~~~~swift
/// let metalEffectPix = MetalEffectPIX(code:
///     """
///     float gamma = 0.25;
///     pix = pow(input, 1.0 / gamma);
///     """
/// )
/// metalEffectPix.input = CameraPIX()
/// ~~~~
final public class MetalEffectPIX: PIXSingleEffect, NODEMetal, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleMetalPIX" }
    
    // MARK: - Private Properties

//    public let metalFileName = "EffectSingleMetalPIX.metal"
    public let metalBaseCode: String =
    """
    #include <metal_stdlib>
    using namespace metal;

    /*<funcs>*/

    struct VertexOut{
        float4 position [[position]];
        float2 texCoord;
    };

    struct Uniforms {
        /*<uniforms>*/
        float aspect;
    };

    fragment float4 effectSingleMetalPIX(VertexOut out [[stage_in]],
                                         texture2d<float>  inTex [[ texture(0) ]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
        float pi = 3.14159265359;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        uint w = inTex.get_width();
        uint h = inTex.get_height();
        float wu = 1.0 / float(w);
        float hv = 1.0 / float(h);
        
        float4 input = inTex.sample(s, uv);
        
        float4 pix = 0.0;
        
        /*<code>*/
        
        return pix;
    }
    """
    
    public override var shaderNeedsAspect: Bool { return true }
    
    public var metalUniforms: [MetalUniform] { didSet { bakeFrag() } }
    
    public var code: String { didSet { bakeFrag() } }
    public var isRawCode: Bool = false
    public var metalCode: String? {
        if isRawCode { return code }
        console = nil
        do {
            return try pixelKit.render.embedMetalCode(uniforms: metalUniforms, code: code, metalBaseCode: metalBaseCode)
        } catch {
            pixelKit.logger.log(node: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    public var console: String?
    public var consoleCallback: ((String) -> ())?
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return metalUniforms.map({ uniform -> CGFloat in return uniform.value })
    }
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init(name: "Metal B", typeName: "pix-effect-single-metal")
    }
    
    required init() {
        metalUniforms = []
        code = ""
        super.init(name: "Metal B", typeName: "pix-effect-single-metal")
    }
    
    func bakeFrag() {
        console = nil
        do {
            let frag = try pixelKit.render.makeMetalFrag(shaderName, from: self)
            try makePipeline(with: frag)
        } catch {
            switch error {
            case Render.ShaderError.metalError(let codeError, let errorFrag):
                pixelKit.logger.log(node: self, .error, nil, "Metal code failed.", e: codeError)
                console = codeError.localizedDescription
                consoleCallback?(console!)
                do {
                    try makePipeline(with: errorFrag)
                } catch {
                    pixelKit.logger.log(node: self, .fatal, nil, "Metal fail failed.", e: error)
                }
            default:
                pixelKit.logger.log(node: self, .fatal, nil, "Metal bake failed.", e: error)
            }
        }
    }
    
    func makePipeline(with frag: MTLFunction) throws {
        let vtx: MTLFunction? = customVertexShaderName != nil ? try pixelKit.render.makeVertexShader(customVertexShaderName!, with: customMetalLibrary) : nil
        pipeline = try pixelKit.render.makeShaderPipeline(frag, with: vtx)
        render()
    }
    
}


public extension NODEOut {
    
    func pixLumaToAlpha() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            float luma = (input.r + input.g + input.b) / 3;
            pix = float4(input.r, input.r, input.r, luma);
            """
        )
        metalEffectPix.name = "lumaToAlpha:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
    func pixIgnoreAlpha() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            pix = float4(input.r, input.g, input.b, 1.0);
            """
        )
        metalEffectPix.name = "ignoreAlpha:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
    func pixPremultiply() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            float4 c = input;
            pix = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
            """
        )
        metalEffectPix.name = "premultiply:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
}
