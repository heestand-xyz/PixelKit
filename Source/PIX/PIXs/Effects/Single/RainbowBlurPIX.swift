//
//  RainbowBlurPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-02.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics
import MetalKit

public class RainbowBlurPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum RainbowBlurStyle: String, CaseIterable {
        case angle
        case zoom
        var index: Int {
            switch self {
            case .angle: return 2
            case .zoom: return 3
            }
        }
    }
    
    public var style: RainbowBlurStyle = .zoom { didSet { setNeedsRender() } }
    /// radius is relative. default at 0.5
    ///
    /// 1.0 at 4K is max, tho at lower resolutions you can go beyond 1.0
    public var radius: LiveFloat = LiveFloat(0.5, limit: true)
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: LiveFloat = LiveFloat(0.0, min: -0.5, max: 0.5)
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, angle, position]
    }
    
    var relRadius: CGFloat {
        let radius = self.radius.uniform
        let relRes: Resolution = ._4K
        let res: Resolution = renderResolution
        let relHeight = res.height.cg / relRes.height.cg
        let relRadius = radius * relHeight //min(radius * relHeight, 1.0)
        let maxRadius: CGFloat = 32 * 10
        let mappedRadius = relRadius * maxRadius
        return mappedRadius //radius.uniform * 32 * 10
    }
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), relRadius, CGFloat(quality.rawValue), angle.uniform, position.x.uniform, position.y.uniform]
    }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    public required init() {
        super.init()
        extend = .hold
        name = "rainbowBlur"
    }
    
}

public extension NODEOut {
    
    func _rainbowBlur(_ radius: LiveFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":rainbowBlur:"
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
    func _zoomRainbowBlur(_ radius: LiveFloat) -> RainbowBlurPIX {
        let rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.name = ":zoom-rainbowBlur:"
        rainbowBlurPix.style = .zoom
        rainbowBlurPix.quality = .epic
        rainbowBlurPix.input = self as? PIX & NODEOut
        rainbowBlurPix.radius = radius
        return rainbowBlurPix
    }
    
}
