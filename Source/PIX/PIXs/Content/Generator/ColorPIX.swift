//
//  ColorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit

public class ColorPIX: PIXGenerator {
    
    override open var shaderName: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [super.color]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Color", typeName: "pix-content-generator-color")
    }
    
}
