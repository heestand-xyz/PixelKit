//
//  MetalMergerEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

/// Metal Shader (Merger Effect)
///
/// vars: pi, u, v, uv, wA, hA, wuA, hvA, inputA, wB, hB, wuB, hvB, inputB, in.resx, in.resy, in.aspect, in.uniform
///
/// float4 inputA = inTexA.sample(s, uv);
///
/// Example:
/// ```swift
/// let metalMergerEffectPix = MetalMergerEffectPIX(code:
///     """
///     return pow(inputA, 1.0 / inputB);
///     """
/// )
/// metalMergerEffectPix.inputA = CameraPIX()
/// metalMergerEffectPix.inputB = ImagePIX("img_name")
/// ```
final public class MetalMergerEffectPIX: PIXMergerEffect, NODEMetal, PIXViewable {
    
    override public var shaderName: String { return "effectMergerMetalPIX" }
    
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
        float resx;
        float resy;
        float aspect;
    };

    fragment float4 effectMergerMetalPIX(VertexOut out [[stage_in]],
                                         texture2d<float>  inTexA [[ texture(0) ]],
                                         texture2d<float>  inTexB [[ texture(1) ]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
        float pi = M_PI_F;
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
        bakeFrag()
    }
    
    required init() {
        metalUniforms = []
        code =
        """
        float4 a = inTexA.sample(s, uv);
        float4 b = inTexB.sample(s, uv);
        return a + b;
        """
        super.init(name: "Metal B", typeName: "pix-effect-merger-metal")
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
