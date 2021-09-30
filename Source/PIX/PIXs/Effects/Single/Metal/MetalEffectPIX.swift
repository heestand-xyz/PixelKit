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
/// **Variables:** pi, u, v, uv, w, h, wu, hv, tex, pix, var.width, var.height, var.aspect, var.uniform
///
/// Example:
/// ```swift
/// let metalEffectPix = MetalEffectPIX(code:
///     """
///     float gamma = 0.25;
///     return pow(pix, 1.0 / gamma);
///     """
/// )
/// metalEffectPix.pix = CameraPIX()
/// ```
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
        float width;
        float height;
        float aspect;
    };

    fragment float4 effectSingleMetalPIX(VertexOut out [[stage_in]],
                                         texture2d<float>  tex [[ texture(0) ]],
                                         const device Uniforms& var [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
        float pi = M_PI_F;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        uint w = tex.get_width();
        uint h = tex.get_height();
        float wu = 1.0 / float(w);
        float hv = 1.0 / float(h);
        
        float4 pix = tex.sample(s, uv);
        
        /*<code>*/
    }
    """
    
    public override var shaderNeedsResolution: Bool { return true }
    
    public var metalUniforms: [MetalUniform] { didSet { bakeFrag() } }
    
    public var code: String { didSet { bakeFrag() } }
    public var isRawCode: Bool = false
    public var metalCode: String? {
        if isRawCode { return code }
        metalConsole = nil
        do {
            return try pixelKit.render.embedMetalCode(uniforms: metalUniforms, code: code, metalBaseCode: metalBaseCode)
        } catch {
            pixelKit.logger.log(node: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    @Published public var metalConsole: String?
    public var metalConsolePublisher: Published<String?>.Publisher { $metalConsole }
    public var consoleCallback: ((String) -> ())?
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return metalUniforms.map({ uniform -> CGFloat in return uniform.value })
    }
    
    // MARK: - Life Cycle
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init(name: "Metal Effect", typeName: "pix-effect-single-metal")
        bakeFrag()
    }
    
    public required init() {
        metalUniforms = []
        code = """
        float4 color = tex.sample(s, uv);
        return color;
        """
        super.init(name: "Metal Effect", typeName: "pix-effect-single-metal")
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
        bakeFrag()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metalUniforms, forKey: .metalUniforms)
        try container.encode(code, forKey: .code)
        try super.encode(to: encoder)
    }
    
    // MARK: Bake Frag
    
    func bakeFrag() {
        metalConsole = nil
        do {
            let frag = try pixelKit.render.makeMetalFrag(shaderName, from: self)
            try makePipeline(with: frag)
        } catch {
            switch error {
            case Render.ShaderError.metalError(let codeError, let errorFrag):
                pixelKit.logger.log(node: self, .error, nil, "Metal code failed.", e: codeError)
                metalConsole = codeError.localizedDescription
                consoleCallback?(metalConsole!)
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
            float luma = (pix.r + pix.g + pix.b) / 3;
            pix = float4(pix.r, pix.g, pix.b, luma);
            """
        )
        metalEffectPix.name = "lumaToAlpha:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
    func pixIgnoreAlpha() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            pix = float4(pix.r, pix.g, pix.b, 1.0);
            """
        )
        metalEffectPix.name = "ignoreAlpha:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
    func pixPremultiply() -> MetalEffectPIX {
        let metalEffectPix = MetalEffectPIX(code:
            """
            float4 c = pix;
            pix = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
            """
        )
        metalEffectPix.name = "premultiply:metalEffectPix"
        metalEffectPix.input = self as? PIX & NODEOut
        return metalEffectPix
    }
    
}
