//
//  MetalMergerEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Metal

/// Metal Shader (Merger Effect)
///
/// vars: pi, u, v, uv, wA, hA, wuA, hvA, inputA, wB, hB, wuB, hvB, inputB
///
/// float4 inputA = inTexA.sample(s, uv);
///
/// Example:
/// ~~~~swift
/// let metalMergerEffectPix = MetalMergerEffectPIX(code:
///     """
///     pix = pow(inputA, 1.0 / inputB);
///     """
/// )
/// metalMergerEffectPix.inputA = CameraPIX()
/// metalMergerEffectPix.inputB = ImagePIX("img_name")
/// ~~~~
final public class MetalMergerEffectPIX: PIXMergerEffect, NODEMetal, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectMergerMetalPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Private Properties
    
//    public let metalFileName = "EffectMergerMetalPIX.metal"
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

    fragment float4 effectMergerMetalPIX(VertexOut out [[stage_in]],
                                         texture2d<float>  inTexA [[ texture(0) ]],
                                         texture2d<float>  inTexB [[ texture(1) ]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
        float pi = 3.14159265359;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        uint wA = inTexA.get_width();
        uint hA = inTexA.get_height();
        uint wB = inTexB.get_width();
        uint hB = inTexB.get_height();
        float wuA = 1.0 / float(wA);
        float hvA = 1.0 / float(hA);
        float wuB = 1.0 / float(wB);
        float hvB = 1.0 / float(hB);
        
        float4 inputA = inTexA.sample(s, uv);
        float4 inputB = inTexB.sample(s, uv);
        
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
        super.init(name: "Metal B", typeName: "pix-effect-merger-metal")
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
