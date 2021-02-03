//
//  LumaBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class LumaBlurPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum LumaBlurStyle: String, CaseIterable, Floatable {
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
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    
    @Live public var style: LumaBlurStyle = .box
    @Live public var radius: CGFloat = 0.5
    @Live public var quality: SampleQualityMode = .mid
    @Live public var angle: CGFloat = 0.0
    @Live public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position] + super.liveList
    }
    
    override public var values: [Floatable] {
        return [radius, angle, position]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Blur", typeName: "pix-effect-merger-luma-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func pixLumaBlur(radius: CGFloat, pix: () -> (PIX & NODEOut)) -> LumaBlurPIX {
        pixLumaBlur(pix: pix(), radius: radius)
    }
    func pixLumaBlur(pix: PIX & NODEOut, radius: CGFloat) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inputA = self as? PIX & NODEOut
        lumaBlurPix.inputB = pix
        lumaBlurPix.radius = radius
        return lumaBlurPix
    }
    
    func pixTiltShift(radius: CGFloat = 0.5, gamma: CGFloat = 0.5) -> LumaBlurPIX {
        let pix = self as! PIX & NODEOut
        let gradientPix = GradientPIX(at: pix.renderResolution)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.direction = .vertical
        gradientPix.offset = 0.5
        gradientPix.scale = 0.5
        gradientPix.extendRamp = .mirror
        return pix.pixLumaBlur(pix: gradientPix !** gamma, radius: radius)
    }
    
}
