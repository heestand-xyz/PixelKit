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
final public class MetalEffectPIX: PIXSingleEffect, NODEMetalCode, PIXViewable {
    
    public typealias Model = MetalEffectPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
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
    
    public override var shaderNeedsResolution: Bool { true }
    
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
        metalUniforms.map(\.value)
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        let model = Model(metalUniforms: uniforms, code: code)
        super.init(model: model)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
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
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: Bake Frag
    
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
