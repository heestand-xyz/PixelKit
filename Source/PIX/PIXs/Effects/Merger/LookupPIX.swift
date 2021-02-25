//
//  LookupPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import CoreGraphics

final public class LookupPIX: PIXMergerEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectMergerLookupPIX" }
    
    // MARK: - Public Properties
    
    public enum Axis: String, Enumable {
        case horizontal
        case vertical
        public var index: Int {
            switch self {
            case .horizontal:
                return 0
            case .vertical:
                return 1
            }
        }
        public var name: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
    @LiveEnum(name: "Axis") public var axis: Axis = .vertical

    var holdEdgeFraction: CGFloat {
        let axisRes = axis == .horizontal ? finalResolution.width : finalResolution.height
        return 1.0 / axisRes
    }
    @LiveBool(name: "Hold Edge") public var holdEdge: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_axis, _holdEdge] + super.liveList
    }
    
    public override var uniforms: [CGFloat] {
        return [axis == .horizontal ? 0 : 1, holdEdge ? 1 : 0, holdEdgeFraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Lookup", typeName: "pix-effect-merger-lookup")
    }
    
    public convenience init(axis: Axis = .vertical,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.axis = axis
    }
    
    // MARK: - Property Funcs
    
    public func pixLookupHoldEdge() -> LookupPIX {
        holdEdge = true
        return self
    }
    
}

public extension NODEOut {
    
    func pixLookup(axis: LookupPIX.Axis = .vertical, pix: () -> (PIX & NODEOut)) -> LookupPIX {
        pixLookup(pix: pix(), axis: axis)
    }
    func pixLookup(pix: PIX & NODEOut, axis: LookupPIX.Axis = .vertical) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = ":lookup:"
        lookupPix.inputA = self as? PIX & NODEOut
        lookupPix.inputB = pix
        lookupPix.axis = axis
        return lookupPix
    }
    
}
