//
//  ArcPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import CoreGraphics
import RenderKit

public class ArcPIX: PIXGenerator, Layoutable {
    
    override open var shaderName: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero
    public var radius: CGFloat = sqrt(0.75) / 4
    public var angleFrom: CGFloat = CGFloat(-0.125, min: -0.5, max: 0.5)
    public var angleTo: CGFloat = CGFloat(0.125, min: -0.5, max: 0.5)
    public var angleOffset: CGFloat = CGFloat(0.0, min: -0.5, max: 0.5)
    public var edgeRadius: CGFloat = CGFloat(0.05, max: 0.5)
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
