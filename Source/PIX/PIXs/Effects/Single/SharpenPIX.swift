//
//  SharpenPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//


import RenderKit

public class SharpenPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleSharpenPIX" }
    
    // MARK: - Public Properties
    
    public var contrast: CGFloat = CGFloat(1.0, min: 0.0, max: 2.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [contrast]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Sharpen", typeName: "pix-effect-single-sharpen")
    }
    
}

public extension NODEOut {
    
    func _sharpen(_ contrast: CGFloat = 1.0) -> SharpenPIX {
        let sharpenPix = SharpenPIX()
        sharpenPix.name = ":sharpen:"
        sharpenPix.input = self as? PIX & NODEOut
        sharpenPix.contrast = contrast
        return sharpenPix
    }
    
}
