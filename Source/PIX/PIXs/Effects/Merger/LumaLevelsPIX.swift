//
//  LumaLevelsPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics
import PixelColor

final public class LumaLevelsPIX: PIXMergerEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectMergerLumaLevelsPIX" }
    
    public var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var brightness: CGFloat = 1.0
    @Live public var darkness: CGFloat = 0.0
    @Live public var contrast: CGFloat = 0.0
    @Live public var gamma: CGFloat = 1.0
    @Live public var inverted: Bool = false
    @Live public var smooth: Bool = false
    @Live public var opacity: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_brightness, _darkness, _contrast, _gamma, _inverted, _smooth, _opacity] + super.liveList
    }
    
    override public var values: [Floatable] {
        [brightness, darkness, contrast, gamma, inverted, smooth, opacity]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Levels", typeName: "pix-effect-merger-luma-levels")
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
        let rectangle = RectanglePIX(at: pix.renderResolution)
        rectangle.backgroundColor = .white
        rectangle.color = .black
        rectangle.name = "vignetting:rectangle"
        rectangle.size = CGSize(width: pix.renderResolution.aspect - inset, height: 1.0 - inset)
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = "vignetting:lumaLevels"
        lumaLevelsPix.inputA = pix
        lumaLevelsPix.inputB = rectangle.pixBlur(radius)
        lumaLevelsPix.gamma = gamma
        return lumaLevelsPix
    }
    
}
