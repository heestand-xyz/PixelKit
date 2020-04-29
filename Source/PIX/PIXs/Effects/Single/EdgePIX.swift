//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-06.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class EdgePIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    public var strength: LiveFloat = LiveFloat(10.0, min: 0.0)
    public var distance: LiveFloat = LiveFloat(1.0, min: 0.0)
    public var colored: LiveBool = false
    public var transparent: LiveBool = false
    public var includeAlpha: LiveBool = false

    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [strength, distance, colored, transparent, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "edge"
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func _edge(_ strength: LiveFloat = 1.0) -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.input = self as? PIX & NODEOut
        edgePix.strength = strength
        return edgePix
    }
    
}
