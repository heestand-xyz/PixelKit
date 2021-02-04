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

final public class LumaRainbowBlurPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerLumaRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum RainbowLumaBlurStyle: String, CaseIterable, Floatable {
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
        public var floats: [CGFloat] { [CGFloat(index)] }
        public init(floats: [CGFloat]) {
            self = Self.allCases.first(where: { $0.index == Int(floats.first ?? 0.0) }) ?? Self.allCases.first!
        }
    }
    
    @Live public var style: RainbowLumaBlurStyle = .angle
    @Live public var radius: CGFloat = 0.5
    @Live public var quality: SampleQualityMode = .mid
    @Live public var angle: CGFloat = 0.0
    @Live public var position: CGPoint = .zero
    @Live public var light: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position, _light] + super.liveList
    }
    
    override public var values: [Floatable] {
        return [radius, angle, position, light]
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, light]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Rainbow Blur", typeName: "pix-effect-merger-luma-rainbow-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func pixLumaRainbowBlur(style: LumaRainbowBlurPIX.RainbowLumaBlurStyle = .zoom,
                            radius: CGFloat,
                            angle: CGFloat = 0.0,
                            position: CGPoint = .zero,
                            light: CGFloat = 1.0,
                            quality: PIX.SampleQualityMode = .mid,
                            pix: () -> (PIX & NODEOut)) -> LumaRainbowBlurPIX {
        pixLumaRainbowBlur(pix: pix(), style: style, radius: radius, angle: angle, position: position, light: light, quality: quality)
    }
    func pixLumaRainbowBlur(pix: PIX & NODEOut,
                            style: LumaRainbowBlurPIX.RainbowLumaBlurStyle = .zoom,
                            radius: CGFloat,
                            angle: CGFloat = 0.0,
                            position: CGPoint = .zero,
                            light: CGFloat = 1.0,
                            quality: PIX.SampleQualityMode = .mid) -> LumaRainbowBlurPIX {
        let lumaRainbowBlurPix = LumaRainbowBlurPIX()
        lumaRainbowBlurPix.name = ":lumaRainbowBlur:"
        lumaRainbowBlurPix.inputA = self as? PIX & NODEOut
        lumaRainbowBlurPix.inputB = pix
        lumaRainbowBlurPix.style = style
        lumaRainbowBlurPix.radius = radius
        lumaRainbowBlurPix.angle = angle
        lumaRainbowBlurPix.position = position
        lumaRainbowBlurPix.light = light
        lumaRainbowBlurPix.quality = quality
        return lumaRainbowBlurPix
    }
    
}
