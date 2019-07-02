//
//  RangePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//


public class RangePIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleRangePIX" }
    
    // MARK: - Public Properties
    
    public var inLow: LiveFloat = 0.0
    public var inHigh: LiveFloat = 1.0
    public var outLow: LiveFloat = 0.0
    public var outHigh: LiveFloat = 1.0
    public var inLowColor: LiveColor = .clear
    public var inHighColor: LiveColor = .white
    public var outLowColor: LiveColor = .clear
    public var outHighColor: LiveColor = .white
    public var ignoreAlpha: LiveBool = true
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [inLow, inHigh, outLow, outHigh, inLowColor, inHighColor, outLowColor, outHighColor, ignoreAlpha]
    }
    
    public required init() {
        super.init()
        name = "range"
    }
    
}

public extension PIXOut {
    
    func _range(inLow: LiveFloat = 0.0, inHigh: LiveFloat = 1.0, outLow: LiveFloat = 0.0, outHigh: LiveFloat = 1.0) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLow = inLow
        rangePix.inHigh = inHigh
        rangePix.outLow = outLow
        rangePix.outHigh = outHigh
        return rangePix
    }
    
    func _range(inLow: LiveColor = .clear, inHigh: LiveColor = .white, outLow: LiveColor = .clear, outHigh: LiveColor = .white) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLowColor = inLow
        rangePix.inHighColor = inHigh
        rangePix.outLowColor = outLow
        rangePix.outHighColor = outHigh
        return rangePix
    }
    
}
