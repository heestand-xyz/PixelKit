//
//  ArcPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

final public class ArcPIX: PIXGenerator, PIXViewable {
    
    public typealias Model = ArcPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("radius", range: 0.0...0.5, increment: 0.125) public var radius: CGFloat = 0.25
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("angleFrom", range: -0.5...0.5, increment: 0.125) public var angleFrom: CGFloat = -0.125
    @LiveFloat("angleTo", range: -0.5...0.5, increment: 0.125) public var angleTo: CGFloat = 0.125
    @LiveFloat("angleOffset", range: -0.5...0.5, increment: 0.125) public var angleOffset: CGFloat = 0.0
    @LiveFloat("edgeRadius", range: 0.0...0.5) public var edgeRadius: CGFloat = 0.0
    @LiveColor("edgeColor") public var edgeColor: PixelColor = .gray
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _radius, _angleFrom, _angleTo, _angleOffset, _edgeRadius, _edgeColor]
    }
    
    override public var values: [Floatable] {
        [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, super.color, edgeColor, super.backgroundColor]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            radius: CGFloat = 0.25,
                            angleFrom: CGFloat = -0.125,
                            angleTo: CGFloat = 0.125) {
        self.init(at: resolution)
        self.radius = radius
        self.angleFrom = angleFrom
        self.angleTo = angleTo
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        radius = model.radius
        position = model.position
        angleFrom = model.angleFrom
        angleTo = model.angleTo
        angleOffset = model.angleOffset
        edgeRadius = model.edgeRadius
        edgeColor = model.edgeColor
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.radius = radius
        model.position = position
        model.angleFrom = angleFrom
        model.angleTo = angleTo
        model.angleOffset = angleOffset
        model.edgeRadius = edgeRadius
        model.edgeColor = edgeColor
        
        super.liveUpdateModelDone()
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
