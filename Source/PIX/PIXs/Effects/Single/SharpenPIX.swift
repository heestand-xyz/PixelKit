//
//  SharpenPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

import Live

public class SharpenPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleSharpenPIX" }
    
    // MARK: - Public Properties
    
    public var contrast: LiveFloat = LiveFloat(1.0, min: 0.0, max: 2.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [contrast]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "sharpen"
    }
    
}

public extension PIXOut {
    
    func _sharpen(_ contrast: LiveFloat = 1.0) -> SharpenPIX {
        let sharpenPix = SharpenPIX()
        sharpenPix.name = ":sharpen:"
        sharpenPix.inPix = self as? PIX & PIXOut
        sharpenPix.contrast = contrast
        return sharpenPix
    }
    
}
