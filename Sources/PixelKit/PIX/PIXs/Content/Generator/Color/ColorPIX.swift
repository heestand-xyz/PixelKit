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

final public class ColorPIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList.filter { liveWrap in
            liveWrap.typeName != "backgroundColor"
        }
    }
    
    override public var values: [Floatable] {
        [super.color]
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
