//
//  PIXMultiEffect.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit
import Resolution

open class PIXMultiEffect: PIXEffect, NODEMultiEffect, NODEInMulti {
    
    var multiEffectModel: PixelMultiEffectModel {
        get { effectModel as! PixelMultiEffectModel }
        set { effectModel = newValue }
    }
    
    public var inputs: [NODE & NODEOut] = [] { didSet { setNeedsConnectMulti(new: inputs, old: oldValue) } }
    
    // MARK: - Life Cycle -
    
    init(model: PixelMultiEffectModel) {
        super.init(model: model)
    }
    
    public required init() {
        fatalError("please use init(model:)")
    }
    
    public override func destroy() {
        inputs = []
        super.destroy()
    }
    
}
