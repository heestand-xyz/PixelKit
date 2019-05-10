//
//  LookupPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics

public class LookupPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerLookupPIX" }
    
    // MARK: - Public Properties
    
    public enum Axis: String, CaseIterable {
        case x
        case y
    }
    
    var holdEdgeFraction: CGFloat {
        guard let res = resolution else { return 0 }
        let axisRes = axis == .x ? res.width.cg : res.height.cg
        return 1 / axisRes
    }
    
    public var axis: Axis = .x { didSet { setNeedsRender() } }
    public var holdEdge: Bool = true { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case axis; case holdEdge
//    }
    
    open override var uniforms: [CGFloat] {
        return [axis == .x ? 0 : 1, holdEdge ? 1 : 0, holdEdgeFraction]
    }
    
}

public extension PIXOut {
    
    func _lookup(with pix: PIX & PIXOut, axis: LookupPIX.Axis) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = ":lookup:"
        lookupPix.inPixA = self as? PIX & PIXOut
        lookupPix.inPixB = pix
        lookupPix.axis = axis
        return lookupPix
    }
    
}
