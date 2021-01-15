//
//  LookupPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

public class LookupPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLookupPIX" }
    
    // MARK: - Public Properties
    
    public enum Axis: Int, CaseIterable, Floatable {
        case x
        case y
        public var floats: [CGFloat] { [CGFloat(rawValue)] }
    }
    
    var holdEdgeFraction: CGFloat {
        let axisRes = axis == .x ? renderResolution.width : renderResolution.height
        return 1 / axisRes
    }
    
    @Live public var axis: Axis = .x
    @Live public var holdEdge: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_axis, _holdEdge] + super.liveList
    }
    
    open override var uniforms: [CGFloat] {
        return [axis == .x ? 0 : 1, holdEdge ? 1 : 0, holdEdgeFraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Lookup", typeName: "pix-effect-merger-lookup")
    }
    
}

public extension NODEOut {
    
    func lookup(with pix: PIX & NODEOut, axis: LookupPIX.Axis) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = ":lookup:"
        lookupPix.inputA = self as? PIX & NODEOut
        lookupPix.inputB = pix
        lookupPix.axis = axis
        return lookupPix
    }
    
}
