//
//  LumaBlurPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class LumaBlurPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum LumaBlurStyle: String, CaseIterable {
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
    
    public var style: LumaBlurStyle = .box { didSet { setNeedsRender() } }
    public var radius: CGFloat = 0.5
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = CGFloat(0.0, min: -0.5, max: 0.5)
    public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, angle, position]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius.uniform * 32 * 10, CGFloat(quality.rawValue), angle.uniform, position.x.uniform, position.y.uniform]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Blur", typeName: "pix-effect-merger-luma-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func _lumaBlur(with pix: PIX & NODEOut, radius: CGFloat) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inputA = self as? PIX & NODEOut
        lumaBlurPix.inputB = pix
        lumaBlurPix.radius = radius
        return lumaBlurPix
    }
    
    func _tiltShift(radius: CGFloat = 0.5, gamma: CGFloat = 0.5) -> LumaBlurPIX {
        let pix = self as! PIX & NODEOut
        let gradientPix = GradientPIX(at: pix.renderResolution)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.direction = .vertical
        gradientPix.offset = 0.5
        gradientPix.scale = 0.5
        gradientPix.extendRamp = .mirror
        return pix._lumaBlur(with: gradientPix !** gamma, radius: radius)
    }
    
}
