//
//  ThresholdPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-17.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics

public class ThresholdPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleThresholdPIX" }
    
    // MARK: - Public Properties
    
    public var threshold: LiveFloat = LiveFloat(0.5, limit: true)

    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [threshold]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Threshold", typeName: "pix-effect-single-threshold")
    }
    
}

public extension NODEOut {
    
    func _threshold(_ threshold: LiveFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.name = ":threshold:"
        thresholdPix.input = self as? PIX & NODEOut
        thresholdPix.threshold = threshold
//        thresholdPix.smooth = true
        return thresholdPix
    }
    
    func _mask(low: LiveFloat, high: LiveFloat) -> BlendPIX {
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
