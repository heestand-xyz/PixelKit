//
//  FlarePIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class FlarePIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleFlarePIX" }
    
    override var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var scale: LiveFloat = 0.25
    public var count: LiveInt = 6
    public var angle: LiveFloat = 0.25
    public var threshold: LiveFloat = 0.95
    public var brightness: LiveFloat = 1.0
    public var gamma: LiveFloat = 0.25
    public var color: LiveColor = .orange
    public var rayRes: LiveInt = 32
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [scale, count, angle, threshold, brightness, gamma, color, rayRes]
    }
    
}

public extension PIXOut {
    
    func _flare() -> FlarePIX {
        let flarePix = FlarePIX()
        flarePix.name = ":flare:"
        flarePix.inPix = self as? PIX & PIXOut
        return flarePix
    }
    
}
