//
//  MetalGeneratorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Metal

/// Metal Shader (Generator)
///
/// vars: pi, u, v, uv
///
/// Example:
/// ~~~~swift
/// let metalPix = MetalPIX(at: ._1080p, code:
///     """
///     pix = float4(u, v, 0.0, 1.0);
///     """
/// )
/// ~~~~
final public class MetalPIX: PIXGenerator, NODEMetal, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorMetalPIX" }
    
    var bodyView: UINSView { pixView }
    
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
        float aspect;
    };

    fragment float4 contentGeneratorMetalPIX(VertexOut out [[stage_in]],
                                             const device Uniforms& in [[ buffer(0) ]]) {
        float pi = 3.14159265359;
        float u = out.texCoord[0];
        float v = 1.0 - out.texCoord[1];
        float2 uv = float2(u, v);
        
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
        return metalUniforms.map({ uniform -> CGFloat in uniform.value })
    }
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        self.code = code
        super.init(at: resolution, name: "Metal A", typeName: "pix-content-generator-metal")
//        bakeFrag()
    }
    
    required init(at resolution: Resolution) {
        metalUniforms = []
        code = ""
        super.init(at: resolution, name: "Metal A", typeName: "pix-content-generator-metal")
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
        setNeedsRender()
    }
    
}

public extension MetalPIX {
    
    static func pixUV(at resolution: Resolution) -> MetalPIX {
        let metalPix = MetalPIX(at: resolution, code:
            """
            pix = float4(u, v, 0.0, 1.0);
            """
        )
        metalPix.name = "uv:metal"
        return metalPix
    }
    
}
