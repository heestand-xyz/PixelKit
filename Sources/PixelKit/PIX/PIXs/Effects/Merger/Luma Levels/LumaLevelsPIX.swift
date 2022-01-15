//
//  LumaLevelsPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class LumaLevelsPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = LumaLevelsPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerLumaLevelsPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("brightness", range: 0.0...2.0) public var brightness: CGFloat = 1.0
    @LiveFloat("darkness") public var darkness: CGFloat = 0.0
    @LiveFloat("contrast") public var contrast: CGFloat = 0.0
    @LiveFloat("gamma", range: 0.0...2.0) public var gamma: CGFloat = 1.0
    @LiveBool("inverted") public var inverted: Bool = false
    @LiveBool("smooth") public var smooth: Bool = false
    @LiveFloat("opacity") public var opacity: CGFloat = 1.0
    @LiveFloat("offset", range: -1.0...1.0) public var offset: CGFloat = 0.0
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_brightness, _darkness, _contrast, _gamma, _inverted, _smooth, _opacity, _offset, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [brightness, darkness, contrast, gamma, inverted, smooth, opacity, offset, lumaGamma]
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
        
        brightness = model.brightness
        darkness = model.darkness
        contrast = model.contrast
        gamma = model.gamma
        inverted = model.inverted
        smooth = model.smooth
        opacity = model.opacity
        offset = model.offset
        lumaGamma = model.lumaGamma
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.brightness = brightness
        model.darkness = darkness
        model.contrast = contrast
        model.gamma = gamma
        model.inverted = inverted
        model.smooth = smooth
        model.opacity = opacity
        model.offset = offset
        model.lumaGamma = lumaGamma

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixLumaLevels(brightness: CGFloat = 1.0, darkness: CGFloat = 0.0, contrast: CGFloat = 0.0, gamma: CGFloat = 1.0, opacity: CGFloat = 1.0, pix: () -> (PIX & NODEOut)) -> LumaLevelsPIX {
        pixLumaLevels(pix: pix(), brightness: brightness, darkness: darkness, contrast: contrast, gamma: gamma, opacity: opacity)
    }
    func pixLumaLevels(pix: PIX & NODEOut, brightness: CGFloat = 1.0, darkness: CGFloat = 0.0, contrast: CGFloat = 0.0, gamma: CGFloat = 1.0, opacity: CGFloat = 1.0) -> LumaLevelsPIX {
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = ":lumaLevels:"
        lumaLevelsPix.inputA = self as? PIX & NODEOut
        lumaLevelsPix.inputB = pix
        lumaLevelsPix.brightness = brightness
        lumaLevelsPix.darkness = darkness
        lumaLevelsPix.contrast = contrast
        lumaLevelsPix.gamma = gamma
        lumaLevelsPix.opacity = opacity
        return lumaLevelsPix
    }
    
    func pixVignetting(radius: CGFloat = 0.5, inset: CGFloat = 0.25, gamma: CGFloat = 0.5) -> LumaLevelsPIX {
        let pix = self as! PIX & NODEOut
        let rectangle = RectanglePIX(at: pix.finalResolution)
        rectangle.backgroundColor = .white
        rectangle.color = .black
        rectangle.name = "vignetting:rectangle"
        rectangle.size = CGSize(width: pix.finalResolution.aspect - inset, height: 1.0 - inset)
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = "vignetting:lumaLevels"
        lumaLevelsPix.inputA = pix
        lumaLevelsPix.inputB = rectangle.pixBlur(radius)
        lumaLevelsPix.gamma = gamma
        return lumaLevelsPix
    }
    
}
