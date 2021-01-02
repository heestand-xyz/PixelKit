//
//  PIXSingleEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit

open class PIXSingleEffect: PIXEffect, NODESingleEffect, NODEInSingleParent {
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    // MARK: - Life Cycle
    
    public required init() {
        fatalError("please use init(name:typeName:)")
    }
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
}
