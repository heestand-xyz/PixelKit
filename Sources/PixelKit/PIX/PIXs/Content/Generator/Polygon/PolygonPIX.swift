//
//  PolygonPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import SwiftUI

final public class PolygonPIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("radius", range: 0.0...0.5, increment: 0.125) public var radius: CGFloat = 0.25
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LiveInt("count", range: 3...12) public var count: Int = 3
    @LiveFloat("cornerRadius", range: 0.0...0.1, increment: 0.025) public var cornerRadius: CGFloat = 0.0
   
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _radius, _rotation, _count, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [radius, position, rotation, count, super.color, super.backgroundColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Polygon", typeName: "pix-content-generator-polygon")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            radius: CGFloat = 0.25,
                            count: Int = 6,
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.radius = radius
        self.count = count
        self.cornerRadius = cornerRadius
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: - Property Funcs
    
    public func pixPolygonPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> PolygonPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixPolygonRotation(_ value: CGFloat) -> PolygonPIX {
        rotation = value
        return self
    }
    
}
