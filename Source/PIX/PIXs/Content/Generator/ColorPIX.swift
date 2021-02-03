//
//  ColorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit

final public class ColorPIX: PIXGenerator, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorColorPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [super.color]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Color", typeName: "pix-content-generator-color")
    }
    
}
