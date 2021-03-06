//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-06.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class EdgePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("strength", range: 0.0...20.0, increment: 5.0) public var strength: CGFloat = 10.0
    @LiveFloat("distance", range: 0.0...2.0) public var distance: CGFloat = 1.0
    @LiveBool("colored") public var colored: Bool = false
    @LiveBool("transparent") public var transparent: Bool = false
    @LiveBool("includeAlpha") public var includeAlpha: Bool = false

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
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
