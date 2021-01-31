//
//  LumaColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-01.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics
import PixelColor

public class LumaColorShiftPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerLumaColorShiftPIX" }
    
    // MARK: - Public Properties
    
    @Live public var hue: CGFloat = 0.0
    @Live public var saturation: CGFloat = 1.0
    @Live public var tintColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_hue, _saturation, _tintColor] + super.liveList
    }
    
    override public var values: [Floatable] {
        [hue, saturation, tintColor]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Color Shift", typeName: "pix-effect-merger-luma-color-shift")
    }
    
}
