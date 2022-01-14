//
//  TintPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-10.
//

import RenderKit
import Resolution
import Foundation
import PixelColor

final public class TintPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = TintPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleTintPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor("color") public var color: PixelColor = PixelColor(red: 1.0, green: 0.5, blue: 0.0)
    
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
    
    func pixTint(_ color: PixelColor) -> TintPIX {
        let tintPix = TintPIX()
        tintPix.name = ":tint:"
        tintPix.input = self as? PIX & NODEOut
        tintPix.color = color
        return tintPix
    }
    
}

