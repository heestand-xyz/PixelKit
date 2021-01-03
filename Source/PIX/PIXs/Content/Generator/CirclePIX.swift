//
//  CirclePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class CirclePIX: PIXGenerator {
    
    // MARK: - Public Properties
    
    public var radius: CGFloat = 0.25
    public var position: CGPoint = .zero
    public var edgeRadius: CGFloat = 0.0
    public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [radius, position, edgeRadius, super.color, edgeColor, super.bgColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Circle", typeName: "pix-content-generator-circle")
    }
    
}
