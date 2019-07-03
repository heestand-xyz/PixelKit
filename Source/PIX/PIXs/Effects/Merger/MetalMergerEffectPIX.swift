//
//  MetalMergerEffectPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

/// Metal Shader (Merger Effect)
///
/// vars: pi, u, v, uv, wA, hA, wuA, hvA, inPixA, wB, hB, wuB, hvB, inPixB
///
/// float4 inPixA = inTexA.sample(s, uv);
///
/// Example:
/// ~~~~swift
/// let metalMergerEffectPix = MetalMergerEffectPIX(code:
///     """
///     pix = pow(inPixA, 1.0 / inPixB);
///     """
/// )
/// metalMergerEffectPix.inPixA = CameraPIX()
/// metalMergerEffectPix.inPixB = ImagePIX("img_name")
/// ~~~~
public class MetalMergerEffectPIX: PIXMergerEffect, PIXMetal {
    
    override open var shader: String { return "effectMergerMetalPIX" }
    
    // MARK: - Private Properties
    
    let metalFileName = "EffectMergerMetalPIX.metal"
    
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
        super.init()
        name = "metalMergerEffect"
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
