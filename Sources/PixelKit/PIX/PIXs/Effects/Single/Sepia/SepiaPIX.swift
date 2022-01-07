//
//  SepiaPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//

import RenderKit
import Resolution
import Foundation
import PixelColor

final public class SepiaPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = SepiaPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleSepiaPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor("color") public var color: PixelColor = .orange
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_color]
    }
    
    override public var values: [Floatable] {
        [color]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        color = model.color
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.color = color
        
        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixSepia(_ color: PixelColor) -> SepiaPIX {
        let sepiaPix = SepiaPIX()
        sepiaPix.name = ":sepia:"
        sepiaPix.input = self as? PIX & NODEOut
        sepiaPix.color = color
        return sepiaPix
    }
    
}

