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
    
    public typealias Model = PolygonPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
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
                            count: Int = 6,
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.radius = radius
        self.count = count
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        radius = model.radius
        position = model.position
        rotation = model.rotation
        count = model.count
        cornerRadius = model.cornerRadius
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.radius = radius
        model.position = position
        model.rotation = rotation
        model.count = count
        model.cornerRadius = cornerRadius
        
        super.liveUpdateModelDone()
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
