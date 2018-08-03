//
//  LevelsPIX.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class LevelsPIX: PIXSingleEffector {
    
    public var brightness: Double = 1.0 { didSet { setNeedsRender() } }
    public var darkness: Double = 0.0 { didSet { setNeedsRender() } }
    public var contrast: Double = 1.0 { didSet { setNeedsRender() } }
    public var gamma: Double = 1.0 { didSet { setNeedsRender() } }
    public var inverted: Bool = false { didSet { setNeedsRender() } }
    public var opacity: Double = 1.0 { didSet { setNeedsRender() } }
    override var shaderUniforms: [Double] {
        return [brightness, darkness, contrast, gamma, inverted ? 1 : 0, opacity]
    }
    
    public init() {
        super.init(shader: "levels")
    }
    
}
