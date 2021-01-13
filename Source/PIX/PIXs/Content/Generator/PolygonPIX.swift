//
//  PolygonPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class PolygonPIX: PIXGenerator {
    
    override open var shaderName: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero
    public var radius: CGFloat = 0.25
    public var rotation: CGFloat = 0.0
    public var vertexCount: Int = 6
    public var cornerRadius: CGFloat = 0.0
   
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [radius, position, rotation, vertexCount, super.color, super.backgroundColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Polygon", typeName: "pix-content-generator-polygon")
    }
    
}
