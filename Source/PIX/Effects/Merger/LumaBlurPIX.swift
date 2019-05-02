//
//  LumaBlurPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//

import CoreGraphics

public class LumaBlurPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerLumaBlurPIX" }
    
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
    public var radius: LiveFloat = 0.5
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: LiveFloat = 0.0
    public var position: LivePoint = .zero
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, angle, position]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius.uniform * 32 * 10, CGFloat(quality.rawValue), angle.uniform, position.x.uniform, position.y.uniform]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        extend = .hold
    }
    
}

public extension PIXOut {
    
    func _lumaBlur(with pix: PIX & PIXOut, radius: LiveFloat) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inPixA = self as? PIX & PIXOut
        lumaBlurPix.inPixB = pix
        lumaBlurPix.radius = radius
        return lumaBlurPix
    }
    
    func _tiltShift(radius: LiveFloat = 0.5, gamma: LiveFloat = 0.5) -> LumaBlurPIX {
        let pix = self as! PIX & PIXOut
        let gradientPix = GradientPIX(res: pix.resolution ?? ._128)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.direction = .vertical
        gradientPix.offset = 0.5
        gradientPix.scale = 0.5
        gradientPix.extendRamp = .mirror
        return pix._lumaBlur(with: gradientPix !** gamma, radius: radius)
    }
    
}
