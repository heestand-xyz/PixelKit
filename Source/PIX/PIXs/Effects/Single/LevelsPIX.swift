//
//  LevelsPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit

final public class LevelsPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleLevelsPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("brightness", range: 0.0...2.0) public var brightness: CGFloat = 1.0
    @LiveFloat("darkness") public var darkness: CGFloat = 0.0
    @LiveFloat("contrast") public var contrast: CGFloat = 0.0
    @LiveFloat("gamma", range: 0.0...2.0) public var gamma: CGFloat = 1.0
    @LiveBool("inverted") public var inverted: Bool = false
    @LiveBool("smooth") public var smooth: Bool = false
    @LiveFloat("opacity") public var opacity: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_brightness, _darkness, _contrast, _gamma, _inverted, _smooth, _opacity]
    }
    
    override public var values: [Floatable] {
        [brightness, darkness, contrast, gamma, inverted, smooth, opacity]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Levels", typeName: "pix-effect-single-levels")
    }
    
}

public extension NODEOut {
    
    func pixBrightness(_ brightness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "brightness:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.brightness = brightness
        return levelsPix
    }
    
    func picDarkness(_ darkness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "darkness:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.darkness = darkness
        return levelsPix
    }
    
    func pixContrast(_ contrast: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "contrast:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.contrast = contrast
        return levelsPix
    }
    
    func pixGamma(_ gamma: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "gamma:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.gamma = gamma
        return levelsPix
    }
    
    func pixInvert() -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "invert:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.inverted = true
        return levelsPix
    }
    
    func pixSmooth() -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "smooth:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.smooth = true
        return levelsPix
    }
    
    func pixOpacity(_ opacity: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "opacity:levels"
        levelsPix.input = self as? PIX & NODEOut
        levelsPix.opacity = opacity
        return levelsPix
    }
    
}
