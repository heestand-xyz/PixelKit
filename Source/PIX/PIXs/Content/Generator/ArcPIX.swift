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
    
    public var position: CGPoint = .zero
    public var radius: CGFloat = sqrt(0.75) / 4
    public var angleFrom: CGFloat = -0.125
    public var angleTo: CGFloat = 0.125
    public var angleOffset: CGFloat = 0.0
    public var edgeRadius: CGFloat = 0.05
    public var fillColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, fillColor, super.color, super.bgColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Arc", typeName: "pix-content-generator-arc")
    }
    
}
