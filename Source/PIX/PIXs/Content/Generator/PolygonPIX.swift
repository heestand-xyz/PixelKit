//
//  PolygonPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import SwiftUI

final public class PolygonPIX: PIXGenerator, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    @Live public var position: CGPoint = .zero
    @Live public var radius: CGFloat = 0.25
    @Live public var rotation: CGFloat = 0.0
    @Live public var vertexCount: Int = 3
    @Live public var cornerRadius: CGFloat = 0.0
   
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _radius, _rotation, _vertexCount, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [radius, position, rotation, vertexCount, super.color, super.backgroundColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Polygon", typeName: "pix-content-generator-polygon")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            radius: CGFloat = 0.25,
                            count vertexCount: Int = 6,
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.radius = radius
        self.vertexCount = vertexCount
        self.cornerRadius = cornerRadius
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
