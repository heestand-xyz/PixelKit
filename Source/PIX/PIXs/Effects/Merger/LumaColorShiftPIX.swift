//
//  LumaColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-01.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class LumaColorShiftPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaColorShiftPIX" }
    
    // MARK: - Public Properties
    
    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 1.0
    public var tintColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [hue, saturation, tintColor]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Color Shift", typeName: "pix-effect-merger-luma-color-shift")
    }
    
}
