//
//  ArcPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import CoreGraphics
import RenderKit

public class ArcPIX: PIXGenerator {
    
    override open var shaderName: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    @Live public var position: CGPoint = .zero
    @Live public var radius: CGFloat = sqrt(0.75) / 4
    @Live public var angleFrom: CGFloat = -0.125
    @Live public var angleTo: CGFloat = 0.125
    @Live public var angleOffset: CGFloat = 0.0
    @Live public var edgeRadius: CGFloat = 0.05
    @Live public var fillColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveProp] {
        super.liveList + [_position, _radius, _angleFrom, _angleTo, _angleOffset, _edgeRadius, _fillColor]
    }
    
    override public var values: [CoreValue] {
        [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, fillColor, super.color, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Arc", typeName: "pix-content-generator-arc")
    }
    
}
