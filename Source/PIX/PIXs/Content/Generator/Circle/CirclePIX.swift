//
//  CirclePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import PixelColor
import SwiftUI

final public class CirclePIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    @Live public var radius: CGFloat = 0.25
    @Live public var position: CGPoint = .zero
    @Live public var edgeRadius: CGFloat = 0.0
    @Live public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_radius, _position, _edgeRadius, _edgeColor]
    }
    override public var values: [Floatable] {
        return [radius, position, edgeRadius, super.color, edgeColor, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Circle", typeName: "pix-content-generator-circle")
        print(":: CirclePIX Init", id, "<---")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            radius: CGFloat = 0.25) {
        self.init(at: resolution)
        self.radius = radius
    }
    
    // MARK: - Property Funcs
    
    public func pixCirclePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CirclePIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixCircleEdgeRadius(_ value: CGFloat) -> CirclePIX {
        edgeRadius = value
        return self
    }
    
    public func pixCircleEdgeColor(_ value: PixelColor) -> CirclePIX {
        edgeColor = value
        return self
    }
    
}