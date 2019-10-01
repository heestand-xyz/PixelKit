//
//  ColorPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import Live

public class ColorPIX: PIXGenerator, PIXAuto {
    
    override open var shader: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [super.color]
    }
    
    // MARK: - Life Cycle
    
    public required init(res: Res = .auto) {
        super.init(res: res)
        name = "color"
    }
    
}
