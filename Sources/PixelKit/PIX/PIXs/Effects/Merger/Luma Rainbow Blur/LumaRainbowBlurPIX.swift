//
//  LumaRainbowBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

@available(*, deprecated, renamed: "LumaRainbowBlurPIX")
public typealias RainbowLumaBlurPIX = LumaRainbowBlurPIX

final public class LumaRainbowBlurPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = LumaRainbowBlurPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerLumaRainbowBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum Style: String, Enumable {
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
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .circle: return "Circle"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            }
        }
    }
    
    @LiveEnum("style") public var style: Style = .angle
    @LiveFloat("radius", increment: 0.125) public var radius: CGFloat = 0.5
    @LiveEnum("quality") public var quality: SampleQualityMode = .high
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("light", range: 1.0...4.0, increment: 1.0) public var light: CGFloat = 1.0
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position, _light, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [radius, angle, position, light, lumaGamma]
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, light, lumaGamma]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        style = model.style
        radius = model.radius
        quality = model.quality
        angle = model.angle
        position = model.position
        light = model.light
        lumaGamma = model.lumaGamma

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.style = style
        model.radius = radius
        model.quality = quality
        model.angle = angle
        model.position = position
        model.light = light
        model.lumaGamma = lumaGamma

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixLumaRainbowBlur(style: LumaRainbowBlurPIX.Style = .zoom,
                            radius: CGFloat,
                            angle: CGFloat = 0.0,
                            position: CGPoint = .zero,
                            light: CGFloat = 1.0,
                            quality: PIX.SampleQualityMode = .default,
                            pix: () -> (PIX & NODEOut)) -> LumaRainbowBlurPIX {
        pixLumaRainbowBlur(pix: pix(), style: style, radius: radius, angle: angle, position: position, light: light, quality: quality)
    }
    func pixLumaRainbowBlur(pix: PIX & NODEOut,
                            style: LumaRainbowBlurPIX.Style = .zoom,
                            radius: CGFloat,
                            angle: CGFloat = 0.0,
                            position: CGPoint = .zero,
                            light: CGFloat = 1.0,
                            quality: PIX.SampleQualityMode = .default) -> LumaRainbowBlurPIX {
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
