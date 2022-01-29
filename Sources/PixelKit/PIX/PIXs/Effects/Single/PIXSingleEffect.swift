//
//  PIXSingleEffect.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit
import Resolution

open class PIXSingleEffect: PIXEffect, NODESingleEffect, NODEInSingle {
    
    public var singleEffectModel: PixelSingleEffectModel {
        get { effectModel as! PixelSingleEffectModel }
        set { effectModel = newValue }
    }
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    // MARK: - Life Cycle -
    
    public init(model: PixelSingleEffectModel) {
        super.init(model: model)
    }
    
    public required init() {
        fatalError("please use init(model:)")
    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
}
