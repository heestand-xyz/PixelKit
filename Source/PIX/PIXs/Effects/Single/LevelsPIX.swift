//
//  LevelsPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class LevelsPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleLevelsPIX" }
    
    // MARK: - Public Properties
    
    public var brightness: CGFloat = 1.0
    public var darkness: CGFloat = 0.0
    public var contrast: CGFloat = 0.0
    public var gamma: CGFloat = 1.0
    public var inverted: Bool = false
    public var smooth: Bool = false
    public var opacity: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [brightness, darkness, contrast, gamma, inverted, smooth, opacity]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Levels", typeName: "pix-effect-single-levels")
    }
    
}

public extension NODEOut {
    
    func _brightness(_ brightness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "brightness:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.brightness = brightness
        return levelsPix
    }
    
    func _darkness(_ darkness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "darkness:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.darkness = darkness
        return levelsPix
    }
    
    func _contrast(_ contrast: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "contrast:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.contrast = contrast
        return levelsPix
    }
    
    func _gamma(_ gamma: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "gamma:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.gamma = gamma
        return levelsPix
    }
    
    func _invert() -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "invert:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.inverted = true
        return levelsPix
    }
    
    func _opacity(_ opacity: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "opacity:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.opacity = opacity
        return levelsPix
    }
    
}
