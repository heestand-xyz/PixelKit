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

final public class RainbowBlurPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum RainbowBlurStyle: String, Enumable {
        case circle
        case angle
        case zoom
        public var index: Int {
            switch self {
            case .circle: return 1
            case .angle: return 2
            case .zoom: return 3
            }
        }
        public var name: String {
            switch self {
            case .circle: return "Circle"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            }
        }
    }
    
    @LiveEnum(name: "Style") public var style: RainbowBlurStyle = .zoom
    @LiveFloat(name: "Radius") public var radius: CGFloat = 0.5
    @LiveEnum(name: "Quality") public var quality: SampleQualityMode = .mid
    @LiveFloat(name: "Angle", range: -0.5...0.5) public var angle: CGFloat = 0.0
    @LivePoint(name: "Position") public var position: CGPoint = .zero
    @LiveFloat(name: "Light", range: 0.0...2.0) public var light: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position, _light]
    }
    
    override public var values: [Floatable] {
        [radius, angle, position, light]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, light]
    }
    
    override public var shaderNeedsAspect: Bool { return true }
    
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
