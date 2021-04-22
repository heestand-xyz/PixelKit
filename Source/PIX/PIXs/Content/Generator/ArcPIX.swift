//
//  ArcPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import Foundation
import CoreGraphics
import RenderKit
import PixelColor

final public class ArcPIX: PIXGenerator, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint(name: "Position") public var position: CGPoint = .zero
    @LiveFloat(name: "Radius", range: 0.0...0.5, increment: 0.125) public var radius: CGFloat = 0.25
    @LiveFloat(name: "Angle From", range: -0.5...0.5) public var angleFrom: CGFloat = -0.125
    @LiveFloat(name: "Angle To", range: -0.5...0.5) public var angleTo: CGFloat = 0.125
    @LiveFloat(name: "Angle Offset", range: -1.0...1.0) public var angleOffset: CGFloat = 0.0
    @LiveFloat(name: "Edge Radius", range: 0.0...0.5) public var edgeRadius: CGFloat = 0.0
    @LiveColor(name: "Edge Color") public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _radius, _angleFrom, _angleTo, _angleOffset, _edgeRadius, _edgeColor]
    }
    
    override public var values: [Floatable] {
        [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, super.color, edgeColor, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Arc", typeName: "pix-content-generator-arc")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            radius: CGFloat = 0.25,
                            angleFrom: CGFloat = -0.125,
                            angleTo: CGFloat = 0.125) {
        self.init(at: resolution)
        self.radius = radius
        self.angleFrom = angleFrom
        self.angleTo = angleTo
    }
    
    // MARK: - Property Funcs
    
    public func pixArcPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> ArcPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixArcAngleOffset(_ value: CGFloat) -> ArcPIX {
        angleOffset = value
        return self
    }
    
    public func pixArcEdgeRadius(_ value: CGFloat) -> ArcPIX {
        edgeRadius = value
        return self
    }
    
    public func pixArcEdgeColor(_ value: PixelColor) -> ArcPIX {
        edgeColor = value
        return self
    }
    
}
