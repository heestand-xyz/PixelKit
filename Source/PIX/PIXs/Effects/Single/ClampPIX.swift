//
//  ClampPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class ClampPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleClampPIX" }
    
    // MARK: - Public Properties
    
    public var low: LiveFloat = 0.0
    public var high: LiveFloat = 1.0
    public var clampAlpha: LiveBool = false
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [low, high, clampAlpha]
    }
    
}

public extension PIXOut {
    
    func _clamp(low: LiveFloat = 0.0, high: LiveFloat = 1.0) -> ClampPIX {
        let clampPix = ClampPIX()
        clampPix.name = ":clamp:"
        clampPix.inPix = self as? PIX & PIXOut
        clampPix.low = low
        clampPix.high = high
        return clampPix
    }
    
}
