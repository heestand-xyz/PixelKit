//
//  RainbowBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-02.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics
import MetalKit

public class RainbowBlurPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum RainbowBlurStyle: String, CaseIterable, Floatable {
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
    }
    
    @Live public var style: RainbowBlurStyle = .zoom
    @Live public var radius: CGFloat = 0.5
    @Live public var quality: SampleQualityMode = .mid
    @Live public var angle: CGFloat = 0.0
    @Live public var position: CGPoint = .zero
    @Live public var light: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position, _light]
    }
    
    override public var values: [Floatable] {
        [radius, angle, position, light]
    }
    
    open override var uniforms: [CGFloat] {
        [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, light]
    }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Rainbow Blur", typeName: "pix-effect-single-rainbow-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func pixRainbowBlur(_ radius: CGFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":rainbowBlur:"
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
    func pixZoomRainbowBlur(_ radius: CGFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":zoom-rainbowBlur:"
        rainbowBlurPix.style = .zoom
        rainbowBlurPix.quality = .epic
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
}
