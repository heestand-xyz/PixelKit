//
//  ThresholdPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-17.
//  Open Source - MIT License
//

import CoreGraphics

public class ThresholdPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleThresholdPIX" }
    
    // MARK: - Public Properties
    
    public var threshold: LiveFloat = 0.5
    public var smooth: LiveBool = false
    var _smoothness: CGFloat = 0
    public var smoothness: LiveFloat {
        set {
            _smoothness = newValue.value
            setNeedsRender()
        }
        get {
            return LiveFloat({ () -> (CGFloat) in
                guard self.smooth.value else { return 0.0 }
                return max(self._smoothness, 1.0 / pow(2.0, CGFloat(PixelKit.main.bits.rawValue)))
            })
        }
    }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [threshold, smoothness]
    }
    
}

public extension PIXOut {
    
    func _threshold(_ threshold: LiveFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.name = ":threshold:"
        thresholdPix.inPix = self as? PIX & PIXOut
        thresholdPix.threshold = threshold
        thresholdPix.smooth = true
        return thresholdPix
    }
    
}
