//
//  LookupPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

public class LookupPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerLookupPIX" }
    
    // MARK: - Public Properties
    
    public enum Axis: String, CaseIterable {
        case x
        case y
    }
    
    var holdEdgeFraction: CGFloat {
        let axisRes = axis == .x ? renderResolution.width : renderResolution.height
        return 1 / axisRes
    }
    
    public var axis: Axis = .x { didSet { setNeedsRender() } }
    public var holdEdge: Bool = true { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [axis == .x ? 0 : 1, holdEdge ? 1 : 0, holdEdgeFraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Lookup", typeName: "pix-effect-merger-lookup")
    }
    
}

public extension NODEOut {
    
    func _lookup(with pix: PIX & NODEOut, axis: LookupPIX.Axis) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = ":lookup:"
        lookupPix.inputA = self as? PIX & NODEOut
        lookupPix.inputB = pix
        lookupPix.axis = axis
        return lookupPix
    }
    
}
