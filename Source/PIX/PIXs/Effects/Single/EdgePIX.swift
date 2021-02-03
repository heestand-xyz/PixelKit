//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-06.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

final public class EdgePIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectSingleEdgePIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var strength: CGFloat = 10.0
    @Live public var distance: CGFloat = 1.0
    @Live public var colored: Bool = false
    @Live public var transparent: Bool = false
    @Live public var includeAlpha: Bool = false

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_strength, _distance, _colored, _transparent, _includeAlpha]
    }
    
    override public var values: [Floatable] {
        [strength, distance, colored, transparent, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Edge", typeName: "pix-effect-single-edge")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func pixEdge(_ strength: CGFloat = 1.0) -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.input = self as? PIX & NODEOut
        edgePix.strength = strength
        return edgePix
    }
    
}
