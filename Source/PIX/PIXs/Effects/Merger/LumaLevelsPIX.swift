//
//  LumaLevelsPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//

import CoreGraphics

public class LumaLevelsPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerLumaLevelsPIX" }
    
    // MARK: - Public Properties
    
    public var brightness: LiveFloat = 1.0
    public var darkness: LiveFloat = 0.0
    public var contrast: LiveFloat = 0.0
    public var gamma: LiveFloat = 1.0
    public var opacity: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [brightness, darkness, contrast, gamma, opacity]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "lumaLevels"
    }
    
}

public extension PIXOut {
    
    func _lumaLevels(with pix: PIX & PIXOut, brightness: LiveFloat = 1.0, darkness: LiveFloat = 0.0, contrast: LiveFloat = 0.0, gamma: LiveFloat = 1.0, opacity: LiveFloat = 1.0) -> LumaLevelsPIX {
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = ":lumaLevels:"
        lumaLevelsPix.inPixA = self as? PIX & PIXOut
        lumaLevelsPix.inPixB = pix
        lumaLevelsPix.brightness = brightness
        lumaLevelsPix.darkness = darkness
        lumaLevelsPix.contrast = contrast
        lumaLevelsPix.gamma = gamma
        lumaLevelsPix.opacity = opacity
        return lumaLevelsPix
    }
    
    func _vignetting(radius: LiveFloat = 0.5, inset: LiveFloat = 0.25, gamma: LiveFloat = 0.5) -> LumaLevelsPIX {
        let pix = self as! PIX & PIXOut
        let rectangle = RectanglePIX(res: pix.resolution ?? ._1024)
        rectangle.bgColor = .white
        rectangle.color = .black
        rectangle.name = "vignetting:rectangle"
        rectangle.size = LiveSize(w: (pix.resolution?.aspect ?? 1.0) - inset, h: 1.0 - inset)
        let lumaLevelsPix = LumaLevelsPIX()
        lumaLevelsPix.name = "vignetting:lumaLevels"
        lumaLevelsPix.inPixA = pix
        lumaLevelsPix.inPixB = rectangle._blur(radius)
        lumaLevelsPix.gamma = gamma
        return lumaLevelsPix
    }
    
}
