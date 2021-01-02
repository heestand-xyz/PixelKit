//
//  PIXMultiEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit

open class PIXMultiEffect: PIXEffect, NODEMultiEffect, NODEInMultiParent {

    public var inputs: [NODE & NODEOut] = [] { didSet { setNeedsConnectMulti(new: inputs, old: oldValue) } }
    
    // MARK: - Life Cycle
    
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
