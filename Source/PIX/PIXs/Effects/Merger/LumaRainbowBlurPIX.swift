//
//  LumaRainbowBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

@available(*, deprecated, message: "New PIX Name: LumaRainbowBlurPIX")
public typealias RainbowLumaBlurPIX = LumaRainbowBlurPIX

public class LumaRainbowBlurPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum RainbowLumaBlurStyle: String, CaseIterable {
        case circle
        case angle
        case zoom
        var index: Int {
            switch self {
            case .circle: return 1
            case .angle: return 2
            case .zoom: return 3
            }
        }
    }
    
    public var style: RainbowLumaBlurStyle = .angle { didSet { setNeedsRender() } }
    public var radius: CGFloat = 0.5
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0.0
    public var position: CGPoint = .zero
    public var light: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [radius, angle, position, light]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, light]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Rainbow Blur", typeName: "pix-effect-merger-luma-rainbow-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    @available(*, deprecated, renamed: "_lumaRainbowBlur(with:radius:angle:)")
    func _rainbowLumaBlur(with pix: PIX & NODEOut, radius: CGFloat, angle: CGFloat) -> LumaRainbowBlurPIX {
        _lumaRainbowBlur(with: pix, radius: radius, angle: angle)
    }
    
    func _lumaRainbowBlur(with pix: PIX & NODEOut, radius: CGFloat, angle: CGFloat) -> LumaRainbowBlurPIX {
        let rainbowLumaBlurPix = LumaRainbowBlurPIX()
        rainbowLumaBlurPix.name = ":rainbowLumaBlur:"
        rainbowLumaBlurPix.inputA = self as? PIX & NODEOut
        rainbowLumaBlurPix.inputB = pix
        rainbowLumaBlurPix.radius = radius
        rainbowLumaBlurPix.angle = angle
        return rainbowLumaBlurPix
    }
    
}
