//
//  LumaColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-01.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class LumaColorShiftPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerLumaColorShiftPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("hue", range: -0.5...0.5) public var hue: CGFloat = 0.0
    @LiveFloat("saturation", range: 0.0...2.0) public var saturation: CGFloat = 1.0
    @LiveColor("tintColor") public var tintColor: PixelColor = .white
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_hue, _saturation, _tintColor, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [hue, saturation, tintColor, lumaGamma]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Color Shift", typeName: "pix-effect-merger-luma-color-shift")
    }
    
    public convenience init(hue: CGFloat = 0.0,
                            saturation: CGFloat = 1.0,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.hue = hue
        self.saturation = saturation
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: - Property Funcs
    
    public func pixLumaColorShiftTint(color: PixelColor) -> LumaColorShiftPIX {
        tintColor = color
        return self
    }
    
}
