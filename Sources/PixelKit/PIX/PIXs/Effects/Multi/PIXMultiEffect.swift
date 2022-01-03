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

    public var inputs: [NODE & NODEOut] = [] { didSet { setNeedsConnectMulti(new: inputs, old: oldValue) } }
    
    // MARK: - Life Cycle -
    
    public required init() {
        fatalError("please use init(name:typeName:)")
    }
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
    }
    
    public override func destroy() {
        inputs = []
        super.destroy()
    }
    
}
