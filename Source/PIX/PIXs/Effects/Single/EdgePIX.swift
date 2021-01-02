//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-06.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class EdgePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    public var strength: CGFloat = 10.0
    public var distance: CGFloat = 1.0
    public var colored: Bool = false
    public var transparent: Bool = false
    public var includeAlpha: Bool = false

    // MARK: - Property Helpers
    
    override public var liveValues: [CoreValue] {
        return [strength, distance, colored, transparent, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Edge", typeName: "pix-effect-single-edge")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func _edge(_ strength: CGFloat = 1.0) -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.input = self as? PIX & NODEOut
        edgePix.strength = strength
        return edgePix
    }
    
}
