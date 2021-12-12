//
//  MetalGeneratorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

/// Metal Shader (Generator)
///
/// **Variables:** pi, u, v, uv, var.width, var.height, var.aspect, var.uniform
///
/// Example:
/// ```swift
/// let metalPix = MetalPIX(at: ._1080p, code:
///     """
///     return float4(u, v, 0.0, 1.0);
///     """
/// )
/// ```
final public class MetalPIX: PIXGenerator, NODEMetalCode, PIXViewable {
    
    override public var shaderName: String { return "contentGeneratorMetalPIX" }
    
    // MARK: - Private Properties

//    public let metalFileName = "ContentGeneratorMetalPIX.metal"
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

    fragment float4 contentGeneratorMetalPIX(VertexOut out [[stage_in]],
                                             const device Uniforms& var [[ buffer(0) ]]) {
        float pi = M_PI_F;
        float u = out.texCoord[0];
        float v = 1.0 - out.texCoord[1];
        float2 uv = float2(u, v);
        
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
        return metalUniforms.map({ uniform -> CGFloat in uniform.value })
    }
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init(at: resolution, name: "Metal A", typeName: "pix-content-generator-metal")
        bakeFrag()
    }
    
    required init(at resolution: Resolution) {
        metalUniforms = []
        code = "return float4(u, v, 0.0, 1.0);"
        super.init(at: resolution, name: "Metal A", typeName: "pix-content-generator-metal")
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

public extension MetalPIX {
    
    static func pixUV(at resolution: Resolution = .auto(render: PixelKit.main.render)) -> MetalPIX {
        let metalPix = MetalPIX(at: resolution, code:
            """
            return float4(u, v, 0.0, 1.0);
            """
        )
        metalPix.name = "uv:metal"
        return metalPix
    }
    
}
