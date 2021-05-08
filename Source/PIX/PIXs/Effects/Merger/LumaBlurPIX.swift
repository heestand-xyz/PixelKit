//
//  LumaBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class LumaBlurPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerLumaBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum LumaBlurStyle: String, Enumable {
        case box
        case angle
        case zoom
        case random
        public var index: Int {
            switch self {
            case .box: return 0
            case .angle: return 1
            case .zoom: return 2
            case .random: return 4
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .box: return "Box"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            case .random: return "Random"
            }
        }
    }
    
    @LiveEnum("style") public var style: LumaBlurStyle = .box
    @LiveFloat("radius", increment: 0.125) public var radius: CGFloat = 0.5
    @LiveEnum("quality") public var quality: SampleQualityMode = .mid
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position] + super.liveList
    }
    
    override public var values: [Floatable] {
        return [radius, angle, position]
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Blur", typeName: "pix-effect-merger-luma-blur")
        extend = .hold
    }
    
    public convenience init(radius: CGFloat = 0.5,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.radius = radius
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: - Property Funcs
    
    public func pixLumaBlurStyle(_ value: LumaBlurStyle) -> LumaBlurPIX {
        style = value
        return self
    }
    
    public func pixLumaBlurQuality(_ value: SampleQualityMode) -> LumaBlurPIX {
        quality = value
        return self
    }
    
    public func pixLumaBlurAngle(_ value: CGFloat) -> LumaBlurPIX {
        angle = value
        return self
    }
    
    public func pixLumaBlurPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> LumaBlurPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
}

public extension NODEOut {
    
    func pixLumaBlur(radius: CGFloat, quality: PIX.SampleQualityMode = .mid, pix: () -> (PIX & NODEOut)) -> LumaBlurPIX {
        pixLumaBlur(pix: pix(), radius: radius, quality: quality)
    }
    func pixLumaBlur(pix: PIX & NODEOut, radius: CGFloat, quality: PIX.SampleQualityMode = .mid) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inputA = self as? PIX & NODEOut
        lumaBlurPix.inputB = pix
        lumaBlurPix.radius = radius
        lumaBlurPix.quality = quality
        return lumaBlurPix
    }
    
    func pixTiltShift(radius: CGFloat = 0.5, gamma: CGFloat = 0.5, offset: CGFloat = 0.0, scale: CGFloat = 1.0, quality: PIX.SampleQualityMode = .high) -> LumaBlurPIX {
        let pix = self as! PIX & NODEOut
        let gradientPix = GradientPIX(at: pix.finalResolution)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.direction = .vertical
        gradientPix.offset = 0.5 + offset
        gradientPix.scale = 0.5 * scale
        gradientPix.extendMode = .mirror
        return pix.pixLumaBlur(pix: gradientPix !** gamma, radius: radius, quality: quality)
    }
    
}
