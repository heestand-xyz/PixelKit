//
//  LinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import CoreGraphics
import RenderKit

public class LinePIX: PIXGenerator {
    
    override open var shaderName: String { return "contentGeneratorLinePIX" }
    
    // MARK: - Public Properties
    
    @Live public var positionFrom: CGPoint = CGPoint(x: -0.25, y: -0.25)
    @Live public var positionTo: CGPoint = CGPoint(x: 0.25, y: 0.25)
    @Live public var scale: CGFloat = 0.01
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveProp] {
        super.liveList + [_positionFrom, _positionTo, _scale]
    }
    
    override public var values: [Floatable] {
        [positionFrom, positionTo, scale, super.color, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Line", typeName: "pix-content-generator-line")
    }
    
}
