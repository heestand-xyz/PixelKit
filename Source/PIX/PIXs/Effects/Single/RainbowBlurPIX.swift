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
    
    public enum RainbowBlurStyle: String, CaseIterable {
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
    
    public var style: RainbowBlurStyle = .zoom { didSet { setNeedsRender() } }
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
    
    override open var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Rainbow Blur", typeName: "pix-effect-single-rainbow-blur")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func _rainbowBlur(_ radius: CGFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":rainbowBlur:"
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
    func _zoomRainbowBlur(_ radius: CGFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":zoom-rainbowBlur:"
        rainbowBlurPix.style = .zoom
        rainbowBlurPix.quality = .epic
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
}
