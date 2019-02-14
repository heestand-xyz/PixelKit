//
//  LevelsPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

public class LevelsPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleLevelsPIX" }
    
    // MARK: - Public Properties
    
    public var brightness: LiveFloat = 1.0
    public var darkness: LiveFloat = 0.0
    public var contrast: LiveFloat = 0.0
    public var gamma: LiveFloat = 1.0
    public var inverted: LiveBool = false
    public var opacity: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [brightness, darkness, contrast, gamma, inverted, opacity]
    }
    
//    enum LevelsCodingKeys: String, CodingKey {
//        case brightness; case darkness; case contrast; case gamma; case inverted; case opacity
//    }
    
//    open override var uniforms: [CGFloat] {
//        return [brightness, darkness, contrast, gamma, inverted ? 1 : 0, opacity]
//    }
    
}

public extension PIXOut {
    
    func _brightness(_ brightness: LiveFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "brightness:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.brightness = brightness
        return levelsPix
    }
    
    func _darkness(_ darkness: LiveFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "darkness:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.darkness = darkness
        return levelsPix
    }
    
    func _contrast(_ contrast: LiveFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "contrast:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.contrast = contrast
        return levelsPix
    }
    
    func _gamma(_ gamma: LiveFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "gamma:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.gamma = gamma
        return levelsPix
    }
    
    func _invert() -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "invert:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.inverted = true
        return levelsPix
    }
    
    func _opacity(_ opacity: LiveFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.name = "opacity:levels"
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.opacity = opacity
        return levelsPix
    }
    
}
