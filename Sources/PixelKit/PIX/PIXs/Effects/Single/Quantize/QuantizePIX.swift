//
//  QuantizePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class QuantizePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = QuantizePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleQuantizePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("fraction") public var fraction: CGFloat = 0.125
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_fraction]
    }
    
    override public var values: [Floatable] {
        [fraction]
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
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        fraction = model.fraction
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.fraction = fraction
        
        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixQuantize(_ fraction: CGFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.name = ":quantize:"
        quantizePix.input = self as? PIX & NODEOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}
