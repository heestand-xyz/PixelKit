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

final public class EdgePIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    @Live(name: "Strength") public var strength: CGFloat = 10.0
    @Live(name: "Distance") public var distance: CGFloat = 1.0
    @Live(name: "Colored") public var colored: Bool = false
    @Live(name: "Transparent") public var transparent: Bool = false
    @Live(name: "Include Alpha") public var includeAlpha: Bool = false

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
