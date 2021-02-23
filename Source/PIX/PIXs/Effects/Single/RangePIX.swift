//
//  RangePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import PixelColor

final public class RangePIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleRangePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat(name: "In Low") public var inLow: CGFloat = 0.0
    @LiveFloat(name: "In High") public var inHigh: CGFloat = 1.0
    @LiveFloat(name: "Out Low") public var outLow: CGFloat = 0.0
    @LiveFloat(name: "Out High") public var outHigh: CGFloat = 1.0
    @LiveColor(name: "In Low Color") public var inLowColor: PixelColor = .clear
    @LiveColor(name: "In High Color") public var inHighColor: PixelColor = .white
    @LiveColor(name: "Out Low Color") public var outLowColor: PixelColor = .clear
    @LiveColor(name: "Out High Color") public var outHighColor: PixelColor = .white
    @LiveBool(name: "Ignore Alpha") public var ignoreAlpha: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_inLow, _inHigh, _outLow, _outHigh, _inLowColor, _inHighColor, _outLowColor, _outHighColor, _ignoreAlpha]
    }
    
    override public var values: [Floatable] {
        [inLow, inHigh, outLow, outHigh, inLowColor, inHighColor, outLowColor, outHighColor, ignoreAlpha]
    }
    
    public required init() {
        super.init(name: "Range", typeName: "pix-effect-single-range")
    }
    
}

public extension NODEOut {
    
    func pixRange(inLow: CGFloat = 0.0, inHigh: CGFloat = 1.0, outLow: CGFloat = 0.0, outHigh: CGFloat = 1.0) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.input = self as? PIX & NODEOut
        rangePix.inLow = inLow
        rangePix.inHigh = inHigh
        rangePix.outLow = outLow
        rangePix.outHigh = outHigh
        return rangePix
    }
    
    func pixRange(inLow: PixelColor = .clear, inHigh: PixelColor = .white, outLow: PixelColor = .clear, outHigh: PixelColor = .white) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.input = self as? PIX & NODEOut
        rangePix.inLowColor = inLow
        rangePix.inHighColor = inHigh
        rangePix.outLowColor = outLow
        rangePix.outHighColor = outHigh
        return rangePix
    }
    
}
