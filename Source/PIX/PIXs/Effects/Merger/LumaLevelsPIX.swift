//
//  LumaLevelsPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class LumaLevelsPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaLevelsPIX" }
    
    // MARK: - Public Properties
    
    public var brightness: CGFloat = 1.0
    public var darkness: CGFloat = 0.0
    public var contrast: CGFloat = 0.0
    public var gamma: CGFloat = 1.0
    public var inverted: LiveBool = false
    public var smooth: LiveBool = false
    public var opacity: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [brightness, darkness, contrast, gamma, inverted, smooth, opacity]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Levels", typeName: "pix-effect-merger-luma-levels")
    }
    
}

public extension NODEOut {
    
    func _lumaLevels(with pix: PIX & NODEOut, brightness: CGFloat = 1.0, darkness: CGFloat = 0.0, contrast: CGFloat = 0.0, gamma: CGFloat = 1.0, opacity: CGFloat = 1.0) -> LumaLevelsPIX {
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
    
    func _vignetting(radius: CGFloat = 0.5, inset: CGFloat = 0.25, gamma: CGFloat = 0.5) -> LumaLevelsPIX {
        let pix = self as! PIX & NODEOut
        let rectangle = RectanglePIX(at: pix.renderResolution)
        rectangle.bgColor = .white
        rectangle.color = .black
        rectangle.name = "vignetting:rectangle"
        rectangle.size = LiveSize(w: pix.renderResolution.aspect - inset, h: 1.0 - inset)
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = "vignetting:lumaLevels"
        lumaLevelsPix.inputA = pix
        lumaLevelsPix.inputB = rectangle._blur(radius)
        lumaLevelsPix.gamma = gamma
        return lumaLevelsPix
    }
    
}
