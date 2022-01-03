//
//  MetalMultiEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

/// Metal Shader (Multi Effect)
///
/// **Variables:** pi, u, v, uv, pixCount, texs, var.width, var.height, var.aspect, var.uniform
///
/// Example:
/// ```swift
/// let metalMultiEffectPix = MetalMultiEffectPIX(code:
///     """
///     float4 pixA = texs.sample(s, uv, 0);
///     float4 pixB = texs.sample(s, uv, 1);
///     float4 pixC = texs.sample(s, uv, 2);
///     return pixA + pixB + pixC;
///     """
/// )
/// metalMultiEffectPix.inputs = [ImagePIX("img_a"), ImagePIX("img_b"), ImagePIX("img_c")]
/// ```
final public class MetalMultiEffectPIX: PIXMultiEffect, NODEMetalCode, PIXViewable {
    
    override public var shaderName: String { return "effectMultiMetalPIX" }
    
    // MARK: - Private Properties
    
    public let metalBaseCode: String =
    """
    #include <metal_stdlib>
    using namespace metal;

    /*<funcs>*/

    struct VertexOut{
        float4 position [[position]];
        float2 texCoord;
    };

    struct Uniforms{
        /*<uniforms>*/
        float width;
        float height;
        float aspect;
    };

    fragment float4 effectMultiMetalPIX(VertexOut out [[stage_in]],
                                          texture2d_array<float>  texs [[ texture(0) ]],
                                          const device Uniforms& var [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
        float pi = M_PI_F;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        
        uint pixCount = texs.get_array_size();
        
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
    
    // MARK: - Life Cycle -
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init(name: "Metal D", typeName: "pix-effect-multi-metal")
        bakeFrag()
    }
    
    #if swift(>=5.5)
    public convenience init(uniforms: [MetalUniform] = [], code: String,
                            @PIXBuilder inputs: () -> ([PIX & NODEOut])) {
        self.init(uniforms: uniforms, code: code)
        super.inputs = inputs()
    }
    #endif
    
    public required init() {
        metalUniforms = []
        code =
        """
        float4 pixA = texs.sample(s, uv, 0);
        float4 pixB = texs.sample(s, uv, 1);
        float4 pixC = texs.sample(s, uv, 2);
        return float4(pixA.r, pixB.g, pixC.b, 1.0);
        """
        super.init(name: "Metal D", typeName: "pix-effect-multi-metal")
        bakeFrag()
    }
    
    // MARK: Codable
    
//    enum CodingKeys: CodingKey {
//        case metalUniforms
//        case code
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
//        code = try container.decode(String.self, forKey: .code)
//        try super.init(from: decoder)
//        bakeFrag()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(metalUniforms, forKey: .metalUniforms)
//        try container.encode(code, forKey: .code)
//        try super.encode(to: encoder)
//    }
    
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
