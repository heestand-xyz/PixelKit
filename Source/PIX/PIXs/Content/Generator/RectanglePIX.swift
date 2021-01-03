//
//  RectanglePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class RectanglePIX: PIXGenerator, Layoutable {
    
    override open var shaderName: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero
    public var size: CGSize = CGSize(width: 0.5, height: 0.5)
    public var cornerRadius: CGFloat = CGFloat(0.0, max: 0.25)
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [size, position/*, rotation*/, cornerRadius, super.color, super.bgColor]
    }
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Rectangle", typeName: "pix-content-generator-rectangle")
    }
    
}
