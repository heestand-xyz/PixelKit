//
//  ThresholdPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-17.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class ThresholdPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = ThresholdPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleThresholdPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("threshold") public var threshold: CGFloat = 0.5

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_threshold]
    }
    
    override public var values: [Floatable] {
        return [threshold]
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
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        threshold = model.threshold
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.threshold = threshold
        
        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixThreshold(_ threshold: CGFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.name = ":threshold:"
        thresholdPix.input = self as? PIX & NODEOut
        thresholdPix.threshold = threshold
//        thresholdPix.smooth = true
        return thresholdPix
    }
    
    func pixThreshold(low: CGFloat, high: CGFloat) -> BlendPIX {
        let thresholdLowPix = ThresholdPIX()
        thresholdLowPix.name = "mask:threshold:low"
        thresholdLowPix.input = self as? PIX & NODEOut
        thresholdLowPix.threshold = low
        let thresholdHighPix = ThresholdPIX()
        thresholdHighPix.name = "mask:threshold:high"
        thresholdHighPix.input = self as? PIX & NODEOut
        thresholdHighPix.threshold = high
        return thresholdLowPix - thresholdHighPix
    }
    
}
