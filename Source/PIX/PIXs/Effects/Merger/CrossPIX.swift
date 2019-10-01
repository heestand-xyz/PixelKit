//
//  CrossPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

import Live

public class CrossPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerCrossPIX" }
    
    // MARK: - Public Properties
    
    public var fraction: LiveFloat = LiveFloat(0.5, limit: true)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [fraction]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "cross"
    }
    
}

public extension PIXOut {
    
    func _cross(with pix: PIX & PIXOut, fraction: LiveFloat) -> CrossPIX {
        let crossPix = CrossPIX()
        crossPix.name = ":cross:"
        crossPix.inPixA = self as? PIX & PIXOut
        crossPix.inPixB = pix
        crossPix.fraction = fraction
        return crossPix
    }
    
}

public func cross(_ pixA: PIX & PIXOut, _ pixB: PIX & PIXOut, at fraction: LiveFloat) -> CrossPIX {
    let crossPix = CrossPIX()
    crossPix.name = ":cross:"
    crossPix.inPixA = pixA
    crossPix.inPixB = pixB
    crossPix.fraction = fraction
    return crossPix
}
