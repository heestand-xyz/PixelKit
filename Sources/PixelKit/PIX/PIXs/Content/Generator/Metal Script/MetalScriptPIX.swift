//
//  MetalScriptPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-30.
//

import CoreGraphics
import RenderKit
import Resolution
import Metal

/// Metal Script
///
/// **Variables:** pi, u, v, var.width, var.height, var.aspect, var.uniform
final public class MetalScriptPIX: PIXGenerator, NODEMetalScript, PIXViewable {
    
    override public var shaderName: String { return "metalScriptPIX" }
    
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
        float colorStyle;
        float width;
        float height;
        float aspect;
    };

    fragment float4 metalScriptPIX(VertexOut out [[stage_in]],
                                   const device Uniforms& var [[ buffer(0) ]]) {
        float pi = M_PI_F;
        float u = out.texCoord[0];
        float v = 1.0 - out.texCoord[1];
        
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
    
    public override var shaderNeedsResolution: Bool { true }
    
    public var metalUniforms: [MetalUniform] { didSet { bakeFrag() } }
    
    public var whiteScript: String { didSet { bakeFrag() } }
    public var redScript: String { didSet { bakeFrag() } }
    public var greenScript: String { didSet { bakeFrag() } }
    public var blueScript: String { didSet { bakeFrag() } }
    public var alphaScript: String { didSet { bakeFrag() } }
    
    public var metalCode: String? {
        metalConsole = nil
        do {
          return try pixelKit.render.embedMetalColorCode(uniforms: metalUniforms,
                                                         whiteCode: colorStyle == .white ? whiteScript : "0.0",
                                                         redCode: colorStyle == .color ? redScript : "0.0",
                                                         greenCode: colorStyle == .color ? greenScript : "0.0",
                                                         blueCode: colorStyle == .color ? blueScript : "0.0",
                                                         alphaCode: alphaScript,
                                                         metalBaseCode: metalBaseCode)
        } catch {
            pixelKit.logger.log(node: self, .error, .metal, "Metal code could not be generated.", e: error)
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
        metalUniforms.map({ uniform -> CGFloat in uniform.value })
    }
    
    public override var extraUniforms: [CGFloat] {
        [CGFloat(colorStyle.index)]
    }
    
    // MARK: - Life Cycle
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), whiteScript: String, alphaScript: String = "1.0", uniforms: [MetalUniform] = []) {
        metalUniforms = uniforms
        self.whiteScript = whiteScript
        self.redScript = "0.0"
        self.greenScript = "0.0"
        self.blueScript = "0.0"
        self.alphaScript = alphaScript
        super.init(at: resolution, name: "Metal Script", typeName: "pix-content-generator-metal-script")
        colorStyle = .white
        bakeFrag()
    }
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), redScript: String, greenScript: String, blueScript: String, alphaScript: String = "1.0", uniforms: [MetalUniform] = []) {
        metalUniforms = uniforms
        self.whiteScript = "0.0"
        self.redScript = redScript
        self.greenScript = greenScript
        self.blueScript = blueScript
        self.alphaScript = alphaScript
        super.init(at: resolution, name: "Metal Script", typeName: "pix-content-generator-metal-script")
        colorStyle = .color
        bakeFrag()
    }
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        metalUniforms = []
        self.whiteScript = "1.0"
        self.redScript = "u"
        self.greenScript = "v"
        self.blueScript = "0.0"
        self.alphaScript = "1.0"
        super.init(at: resolution, name: "Metal Script", typeName: "pix-content-generator-metal-script")
        colorStyle = .color
        bakeFrag()
    }
    
    // MARK: Codable
    
//    enum CodingKeys: CodingKey {
//        case metalUniforms
//        case whiteScript
//        case redScript
//        case greenScript
//        case blueScript
//        case alphaScript
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
//        whiteScript = try container.decode(String.self, forKey: .whiteScript)
//        redScript = try container.decode(String.self, forKey: .redScript)
//        greenScript = try container.decode(String.self, forKey: .greenScript)
//        blueScript = try container.decode(String.self, forKey: .blueScript)
//        alphaScript = try container.decode(String.self, forKey: .alphaScript)
//        try super.init(from: decoder)
//        bakeFrag()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(metalUniforms, forKey: .metalUniforms)
//        try container.encode(whiteScript, forKey: .whiteScript)
//        try container.encode(redScript, forKey: .redScript)
//        try container.encode(greenScript, forKey: .greenScript)
//        try container.encode(blueScript, forKey: .blueScript)
//        try container.encode(alphaScript, forKey: .alphaScript)
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

public extension MetalScriptPIX {
    
    static func pixMetalScript(at resolution: Resolution = .auto(render: PixelKit.main.render), white: String, alpha: String = "1.0") -> MetalScriptPIX {
        let metalScriptPix = MetalScriptPIX(at: resolution, whiteScript: white, alphaScript: alpha)
        metalScriptPix.name = "metalScript:white"
        return metalScriptPix
    }
    
    static func pixMetalScript(at resolution: Resolution = .auto(render: PixelKit.main.render), red: String, green: String, blue: String, alpha: String = "1.0") -> MetalScriptPIX {
        let metalScriptPix = MetalScriptPIX(at: resolution, redScript: red, greenScript: green, blueScript: blue, alphaScript: alpha)
        metalScriptPix.name = "metalScript:color"
        return metalScriptPix
    }
    
}
