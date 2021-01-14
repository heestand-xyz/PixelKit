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
    
    @Live public var radius: CGFloat = 0.25
    @Live public var position: CGPoint = .zero
    @Live public var edgeRadius: CGFloat = 0.0
    @Live public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveProp] {
        super.liveList + [_radius, _position, _edgeRadius, _edgeColor]
    }
    override public var values: [CoreValue] {
        return [radius, position, edgeRadius, super.color, edgeColor, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Circle", typeName: "pix-content-generator-circle")
    }
    
}
