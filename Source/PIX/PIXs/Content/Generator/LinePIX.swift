//
//  LinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//


import RenderKit

public class LinePIX: PIXGenerator, Layoutable {
    
    override open var shaderName: String { return "contentGeneratorLinePIX" }
    
    // MARK: - Public Properties
    
    public var positionFrom: CGPoint = CGPoint(x: -0.25, y: -0.25)
    public var positionTo: CGPoint = CGPoint(x: 0.25, y: 0.25)
    public var scale: CGFloat = CGFloat(0.01, max: 0.1)
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [positionFrom, positionTo, scale, super.color, super.bgColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Line", typeName: "pix-content-generator-line")
    }
    
}
