//
//  MetalScriptMergerEffectPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-30.
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

/// Metal Script Merger Effect
///
/// **Variables:** pi, u, v, uv, wA, hA, wuA, hvA, wB, hB, wuB, hvB, texA, texB, pixA, pixB, var.width, var.height, var.aspect, var.uniform
final public class MetalScriptMergerEffectPIX: PIXMergerEffect, NODEMetalScript, PIXViewable {
    
    public typealias Model = MetalScriptMergerEffectPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "metalScriptMergerEffectPIX" }
    
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
        float colorStyle;
        float width;
        float height;
        float aspect;
    };

    fragment float4 metalScriptMergerEffectPIX(VertexOut out [[stage_in]],
                                               texture2d<float>  texA [[ texture(0) ]],
                                               texture2d<float>  texB [[ texture(1) ]],
                                               const device Uniforms& var [[ buffer(0) ]],
                                               sampler s [[ sampler(0) ]]) {
        float pi = M_PI_F;
        float u = out.texCoord[0];
        float v = out.texCoord[1];
        float2 uv = float2(u, v);
        uint wA = texA.get_width();
        uint hA = texA.get_height();
        uint wB = texB.get_width();
        uint hB = texB.get_height();
        float wuA = 1.0 / float(wA);
        float hvA = 1.0 / float(hA);
        float wuB = 1.0 / float(wB);
        float hvB = 1.0 / float(hB);
        
        float4 pixA = texA.sample(s, uv);
        float4 pixB = texB.sample(s, uv);
        float redA = pixA.r;
        float redB = pixB.r;
        float greenA = pixA.g;
        float greenB = pixB.g;
        float blueA = pixA.b;
        float blueB = pixB.b;
        float alphaA = pixA.a;
        float alphaB = pixB.a;
        float whiteA = (redA + greenA + blueA) / 3;
        float whiteB = (redB + greenB + blueB) / 3;
        
        bool inColor = var.colorStyle > 0;
    
        if (inColor) {
            return float4(/*<red>*/, /*<green>*/, /*<blue>*/, /*<alpha>*/);
        } else {
            return float4(float3(/*<white>*/), /*<alpha>*/);
        }
    }
    """
    
    public enum ColorStyle: String, Enumable {
        case white
        case color
        public var index: Int {
            switch self {
            case .white:
                return 0
            case .color:
                return 1
            }
        }
        public var name: String {
            switch self {
            case .white:
                return "White"
            case .color:
                return "Color"
            }
        }
        public var typeName: String {
            rawValue
        }
    }
    @LiveEnum("colorStyle") public var colorStyle: ColorStyle = .color
    
    public override var shaderNeedsResolution: Bool { return true }
    
    public var metalUniforms: [MetalUniform] {
        get { model.metalUniforms }
        set {
            model.metalUniforms = newValue
            listenToUniforms()
            bakeFrag()
        }
    }
    
    public var whiteScript: String {
        get { model.whiteScript }
        set {
            model.whiteScript = newValue
            bakeFrag()
        }
    }
    public var redScript: String {
        get { model.redScript }
        set {
            model.redScript = newValue
            bakeFrag()
        }
    }
    public var greenScript: String {
        get { model.greenScript }
        set {
            model.greenScript = newValue
            bakeFrag()
        }
    }
    public var blueScript: String {
        get { model.blueScript }
        set {
            model.blueScript = newValue
            bakeFrag()
        }
    }
    public var alphaScript: String {
        get { model.alphaScript }
        set {
            model.alphaScript = newValue
            bakeFrag()
        }
    }
    
    public var metalCode: String? {
        metalConsole = nil
        do {
            return try PixelKit.main.render.embedMetalColorCode(uniforms: metalUniforms,
                                                           whiteCode: colorStyle == .white ? whiteScript : "0.0",
                                                           redCode: colorStyle == .color ? redScript : "0.0",
                                                           greenCode: colorStyle == .color ? greenScript : "0.0",
                                                           blueCode: colorStyle == .color ? blueScript : "0.0",
                                                           alphaCode: alphaScript,
                                                           metalBaseCode: metalBaseCode)
        } catch {
            PixelKit.main.logger.log(node: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    
    @Published public var metalConsole: String?
    public var metalConsolePublisher: Published<String?>.Publisher { $metalConsole }
    public var consoleCallback: ((String) -> ())?
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_colorStyle]
    }
    
    override public var values: [Floatable] {
        metalUniforms.map(\.value)
    }
    
    public override var extraUniforms: [CGFloat] {
        [CGFloat(colorStyle.index)]
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
    
    public init(whiteScript: String, alphaScript: String = "1.0", uniforms: [MetalUniform] = []) {
        let model = Model(colorStyle: .white, metalUniforms: uniforms, whiteScript: whiteScript, alphaScript: alphaScript)
        super.init(model: model)
        setup()
    }
    
    public init(redScript: String, greenScript: String, blueScript: String, alphaScript: String = "1.0", uniforms: [MetalUniform] = []) {
        let model = Model(colorStyle: .color, metalUniforms: uniforms, redScript: redScript, greenScript: greenScript, blueScript: blueScript, alphaScript: alphaScript)
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
        
        colorStyle = model.colorStyle
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.colorStyle = colorStyle
        
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
