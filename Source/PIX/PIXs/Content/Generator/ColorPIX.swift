//
//  ColorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import PixelColor

final public class ColorPIX: PIXGenerator, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [super.color]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Color", typeName: "pix-content-generator-color")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            color: PixelColor) {
        self.init(at: resolution)
        super.color = color
    }
    
}
