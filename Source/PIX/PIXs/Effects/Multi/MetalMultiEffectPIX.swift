//
//  MetalMultiEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Metal

/// Metal Shader (Multi Effect)
///
/// vars: pi, u, v, uv, pixCount
///
/// Example:
/// ~~~~swift
/// let metalMultiEffectPix = MetalMultiEffectPIX(code:
///     """
///     float4 inputA = inTexs.sample(s, uv, 0);
///     float4 inputB = inTexs.sample(s, uv, 1);
///     float4 inputC = inTexs.sample(s, uv, 2);
///     pix = inputA + inputB + inputC;
///     """
/// )
/// metalMultiEffectPix.inputs = [ImagePIX("img_a"), ImagePIX("img_b"), ImagePIX("img_c")]
/// ~~~~
final public class MetalMultiEffectPIX: PIXMultiEffect, NODEMetal, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectMultiMetalPIX" }
    
    public var bodyView: UINSView { pixView }
    
    // MARK: - Private Properties
    
//    public let metalFileName = "EffectMultiMetalPIX.metal"
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
        float aspect;
    };

    fragment float4 effectMultiMetalPIX(VertexOut out [[stage_in]],
                                          texture2d_array<float>  inTexs [[ texture(0) ]],
                                          const device Uniforms& in [[ buffer(0) ]],
                                          sampler s [[ sampler(0) ]]) {
        float pi = 3.14159265359;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        
        uint pixCount = inTexs.get_array_size();
        // float4 inputN = inTexs.sample(s, uv, n);
        
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
        self.code = code
        super.init(name: "Metal D", typeName: "pix-effect-multi-metal")
    }
    
    public convenience init(uniforms: [MetalUniform] = [], code: String,
                            @PIXBuilder inputs: () -> ([PIX & NODEOut])) {
        self.init(uniforms: uniforms, code: code)
        super.inputs = inputs()
    }
    
    required init() {
        metalUniforms = []
        code = ""
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
        setNeedsRender()
    }
    
}
