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
import Resolution
import PixelColor

final public class RangePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = RangePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleRangePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("inLow") public var inLow: CGFloat = 0.0
    @LiveFloat("inHigh") public var inHigh: CGFloat = 1.0
    @LiveFloat("outLow") public var outLow: CGFloat = 0.0
    @LiveFloat("outHigh") public var outHigh: CGFloat = 1.0
    @LiveColor("inLowColor") public var inLowColor: PixelColor = .clear
    @LiveColor("inHighColor") public var inHighColor: PixelColor = .white
    @LiveColor("outLowColor") public var outLowColor: PixelColor = .clear
    @LiveColor("outHighColor") public var outHighColor: PixelColor = .white
    @LiveBool("ignoreAlpha") public var ignoreAlpha: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_inLow, _inHigh, _outLow, _outHigh, _inLowColor, _inHighColor, _outLowColor, _outHighColor, _ignoreAlpha]
    }
    
    override public var values: [Floatable] {
        [inLow, inHigh, outLow, outHigh, inLowColor, inHighColor, outLowColor, outHighColor, ignoreAlpha]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        inLow = model.inLow
        inHigh = model.inHigh
        outLow = model.outLow
        outHigh = model.outHigh
        inLowColor = model.inLowColor
        inHighColor = model.inHighColor
        outLowColor = model.outLowColor
        outHighColor = model.outHighColor
        ignoreAlpha = model.ignoreAlpha
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.inLow = inLow
        model.inHigh = inHigh
        model.outLow = outLow
        model.outHigh = outHigh
        model.inLowColor = inLowColor
        model.inHighColor = inHighColor
        model.outLowColor = outLowColor
        model.outHighColor = outHighColor
        model.ignoreAlpha = ignoreAlpha
        
        super.liveUpdateModelDone()
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
