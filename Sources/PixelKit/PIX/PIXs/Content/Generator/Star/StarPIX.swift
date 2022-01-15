//
//  StarPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import SwiftUI

final public class StarPIX: PIXGenerator, PIXViewable {
    
    public typealias Model = StarPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorStarPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("leadingRadius", range: 0.0...0.5, increment: 0.125) public var leadingRadius: CGFloat = 0.25
    @LiveFloat("trailingRadius", range: 0.0...0.5, increment: 0.125) public var trailingRadius: CGFloat = 0.125
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LiveInt("count", range: 3...12) public var count: Int = 5
    @LiveFloat("cornerRadius", range: 0.0...0.1, increment: 0.025) public var cornerRadius: CGFloat = 0.0
   
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _leadingRadius, _trailingRadius, _rotation, _count, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [leadingRadius, trailingRadius, position, rotation, count, super.color, super.backgroundColor, cornerRadius]
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
                            leadingRadius: CGFloat = 0.125,
                            trailingRadius: CGFloat = 0.25,
                            count: Int = 5,
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.leadingRadius = leadingRadius
        self.trailingRadius = trailingRadius
        self.count = count
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        position = model.position
        leadingRadius = model.leadingRadius
        trailingRadius = model.trailingRadius
        rotation = model.rotation
        count = model.count
        cornerRadius = model.cornerRadius
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.position = position
        model.leadingRadius = leadingRadius
        model.trailingRadius = trailingRadius
        model.rotation = rotation
        model.count = count
        model.cornerRadius = cornerRadius
        
        super.liveUpdateModelDone()
    }
}
