//
//  RectanglePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class RectanglePIX: PIXGenerator, PIXViewable {
    
    public typealias Model = RectanglePixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveSize("size") public var size: CGSize = CGSize(width: 0.5, height: 0.5)
    @LiveFloat("cornerRadius", range: 0.0...0.1) public var cornerRadius: CGFloat = 0.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _size, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [size, position, cornerRadius, super.color, super.backgroundColor]
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
                            size: CGSize = CGSize(width: 0.5, height: 0.5),
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        position = model.position
        size = model.size
        cornerRadius = model.cornerRadius
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.position = position
        model.size = size
        model.cornerRadius = cornerRadius
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Property Funcs
    
    public func pixRectanglePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> RectanglePIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
}
