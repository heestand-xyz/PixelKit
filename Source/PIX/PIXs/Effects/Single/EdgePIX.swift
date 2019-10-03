//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-06.
//  Open Source - MIT License
//

import LiveValues

public class EdgePIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    public var strength: LiveFloat = LiveFloat(1.0, min: 0.0, max: 10.0)
    public var distance: LiveFloat = LiveFloat(1.0, min: 0.0, max: 10.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [strength, distance]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "edge"
    }
    
}

public extension NODEOut {
    
    func _edge(_ strength: LiveFloat = 1.0) -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.inPix = self as? PIX & NODEOut
        edgePix.strength = strength
        return edgePix
    }
    
}
