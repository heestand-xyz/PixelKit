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
    
    public typealias Model = MetalPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
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
    
    public var metalUniforms: [MetalUniform] {
        get { model.metalUniforms }
        set {
            model.metalUniforms = newValue
            listenToUniforms()
            bakeFrag()
        }
    }
    
    public var code: String{
        get { model.code }
        set {
            model.code = newValue
            bakeFrag()
        }
    }
    
    public var isRawCode: Bool = false
    
    public var metalCode: String? {
        if isRawCode { return code }
        metalConsole = nil
        do {
            return try PixelKit.main.render.embedMetalCode(uniforms: metalUniforms, code: code, metalBaseCode: metalBaseCode)
        } catch {
            PixelKit.main.logger.log(node: self, .error, .metal, "Metal code could not be generated.", e: error)
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
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setupMetal()
    }
    
    public init(at resolution: Resolution = .auto, uniforms: [MetalUniform] = [], code: String) {
        let model = Model(resolution: resolution, metalUniforms: uniforms, code: code)
        super.init(model: model)
        setupMetal()
    }
    
    public required init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
        setupMetal()
    }
    
    // MARK: - Setup
    
    private func setupMetal() {
        bakeFrag()
        listenToUniforms()
    }
    
    // MARK: - Listen to Uniforms
    
    private func listenToUniforms() {
        for uniform in metalUniforms {
            uniform.didChangeValue = { [weak self] in
                self?.render()
            }
        }
    }
    
    // MARK: - Model
    
    override func modelUpdated() {
        super.modelUpdated()
        
        bakeFrag()
        listenToUniforms()
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Bake Frag
    
    func bakeFrag() {
        metalConsole = nil
        do {
            let frag = try PixelKit.main.render.makeMetalFrag(shaderName, from: self)
            try makePipeline(with: frag)
        } catch {
            switch error {
            case Render.ShaderError.metalError(let codeError, let errorFrag):
                PixelKit.main.logger.log(node: self, .error, nil, "Metal code failed.", e: codeError)
                metalConsole = codeError.localizedDescription
                consoleCallback?(metalConsole!)
                do {
                    try makePipeline(with: errorFrag)
                } catch {
                    PixelKit.main.logger.log(node: self, .fatal, nil, "Metal fail failed.", e: error)
                }
            default:
                PixelKit.main.logger.log(node: self, .fatal, nil, "Metal bake failed.", e: error)
            }
        }
    }
    
    func makePipeline(with frag: MTLFunction) throws {
        pipeline = try PixelKit.main.render.makeShaderPipeline(frag, with: nil)
        render()
    }
    
}

public extension MetalPIX {
    
    static func pixUV(at resolution: Resolution = .auto) -> MetalPIX {
        let metalPix = MetalPIX(at: resolution, code:
            """
            return float4(u, v, 0.0, 1.0);
            """
        )
        metalPix.name = "uv:metal"
        return metalPix
    }
    
}
