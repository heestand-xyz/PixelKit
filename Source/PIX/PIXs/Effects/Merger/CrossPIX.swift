//
//  CrossPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class CrossPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerCrossPIX" }
    
    // MARK: - Public Properties
    
    public var fraction: LiveFloat = LiveFloat(0.5, limit: true)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [fraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Cross", typeName: "pix-effect-merger-cross")
    }
    
}

public extension NODEOut {
    
    func _cross(with pix: PIX & NODEOut, fraction: LiveFloat) -> CrossPIX {
        let crossPix = CrossPIX()
        crossPix.name = ":cross:"
        crossPix.inputA = self as? PIX & NODEOut
        crossPix.inputB = pix
        crossPix.fraction = fraction
        return crossPix
    }
    
}

public func cross(_ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut, at fraction: LiveFloat) -> CrossPIX {
    let crossPix = CrossPIX()
    crossPix.name = ":cross:"
    crossPix.inputA = pixA
    crossPix.inputB = pixB
    crossPix.fraction = fraction
    return crossPix
}
