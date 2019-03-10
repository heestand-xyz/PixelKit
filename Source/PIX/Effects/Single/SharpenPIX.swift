//
//  SharpenPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

public class SharpenPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleSharpenPIX" }
    
    // MARK: - Public Properties
    
    public var contrast: LiveFloat = 1.0
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [contrast]
    }
    
    public override required init() {
        super.init()
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
