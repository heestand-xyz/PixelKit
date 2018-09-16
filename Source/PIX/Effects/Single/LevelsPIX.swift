//
//  LevelsPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func brightness(_ brightness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.brightness = brightness
        return levelsPix
    }
    
    func darkness(_ darkness: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.darkness = darkness
        return levelsPix
    }
    
    func contrast(_ contrast: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.contrast = contrast
        return levelsPix
    }
    
    func gamma(_ gamma: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.gamma = gamma
        return levelsPix
    }
    
    func invert() -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.inverted = true
        return levelsPix
    }
    
    func opacity(_ opacity: CGFloat) -> LevelsPIX {
        let levelsPix = LevelsPIX()
        levelsPix.inPix = self as? PIX & PIXOut
        levelsPix.opacity = opacity
        return levelsPix
    }
    
}

public class LevelsPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .levels
    
    override open var shader: String { return "effectSingleLevelsPIX" }
    
    public var brightness: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var darkness: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var contrast: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var gamma: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var inverted: Bool = false { didSet { setNeedsRender() } }
    public var opacity: CGFloat = 1.0 { didSet { setNeedsRender() } }
    enum LevelsCodingKeys: String, CodingKey {
        case brightness; case darkness; case contrast; case gamma; case inverted; case opacity
    }
    override var uniforms: [CGFloat] {
        return [brightness, darkness, contrast, gamma, inverted ? 1 : 0, opacity]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: LevelsCodingKeys.self)
        brightness = try container.decode(CGFloat.self, forKey: .brightness)
        darkness = try container.decode(CGFloat.self, forKey: .darkness)
        contrast = try container.decode(CGFloat.self, forKey: .contrast)
        gamma = try container.decode(CGFloat.self, forKey: .gamma)
        inverted = try container.decode(Bool.self, forKey: .inverted)
        opacity = try container.decode(CGFloat.self, forKey: .opacity)
        setNeedsRender()
//        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
//        let id = UUID(uuidString: try topContainer.decode(String.self, forKey: .id))! // CHECK BANG
//        super.init(id: id)
    }
    
    public override func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: LevelsCodingKeys.self)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(darkness, forKey: .darkness)
        try container.encode(contrast, forKey: .contrast)
        try container.encode(gamma, forKey: .gamma)
        try container.encode(inverted, forKey: .inverted)
        try container.encode(opacity, forKey: .opacity)
    }
    
}
