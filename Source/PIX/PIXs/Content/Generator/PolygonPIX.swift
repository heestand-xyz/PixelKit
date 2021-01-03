//
//  PolygonPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//


import RenderKit

public class PolygonPIX: PIXGenerator, Layoutable {
    
    override open var shaderName: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero
    public var radius: CGFloat = CGFloat(0.25, max: 0.5)
    public var rotation: CGFloat = CGFloat(0.0, min: -0.5, max: 0.5)
    public var vertexCount: Int = Int(6, min: 3, max: 12)
    public var cornerRadius: CGFloat = CGFloat(0.0, max: 0.25)
   
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [radius, position, rotation, vertexCount, super.color, super.bgColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Polygon", typeName: "pix-content-generator-polygon")
    }
    
}
