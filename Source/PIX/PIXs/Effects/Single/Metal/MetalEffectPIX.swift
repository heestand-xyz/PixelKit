//
//  MetalEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
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
final public class MetalEffectPIX: PIXSingleEffect, NODEMetal, PIXViewable {
    
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
        float resx;
        float resy;
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
    
    public override var shaderNeedsResolution: Bool { return true }
    
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
        bakeFrag()
    }
    
    required init() {
        metalUniforms = []
        code = ""
        super.init(name: "Metal B", typeName: "pix-effect-single-metal")
        bakeFrag()
    }
    
    // MARK: Codable
    
    enum CodingKeys: CodingKey {
        case metalUniforms
        case code
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
        code = try container.decode(String.self, forKey: .code)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metalUniforms, forKey: .metalUniforms)
        try container.encode(code, forKey: .code)
        try super.encode(to: encoder)
    }
    
    // MARK: Bake Frag
    
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
        pipeline = try pixelKit.render.makeShaderPipeline(frag, with: nil)
        render()
    }
    
}


public extension NODEOut {
    
    func pixLumaToAlpha() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            float luma = (input.r + input.g + input.b) / 3;
            pix = float4(input.r, input.g, input.b, luma);
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
