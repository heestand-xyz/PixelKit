//
//  LumaBlurPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//
import CoreGraphics//x

public class LumaBlurPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerLumaBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum Style: String, Codable {
        case box
        case angle
        case zoom
        case random
        var index: Int {
            switch self {
            case .box: return 0
            case .angle: return 1
            case .zoom: return 2
            case .random: return 4
            }
        }
    }
    
    public var style: Style = .box { didSet { setNeedsRender() } }
    public var radius: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case style; case radius; case quality; case angle; case position
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        extend = .hold
    }
    
}

public extension PIXOut {
    
    func _lumaBlur(with pix: PIX & PIXOut, radius: CGFloat) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inPixA = self as? PIX & PIXOut
        lumaBlurPix.inPixB = pix
        lumaBlurPix.radius = radius
        return lumaBlurPix
    }
    
    func _tiltShift(radius: CGFloat = 0.5, gamma: LiveFloat = 0.5) -> LumaBlurPIX {
        let pix = self as! PIX & PIXOut
        let gradientPix = GradientPIX(res: pix.resolution ?? ._128)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.style = .vertical
        gradientPix.offset = 0.5
        gradientPix.scale = 0.5
        gradientPix.extendRamp = .mirror
        return pix._lumaBlur(with: gradientPix !** gamma, radius: radius)
    }
    
}
