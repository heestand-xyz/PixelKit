//
//  PIXMultiEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit

open class PIXMultiEffect: PIXEffect, NODEMultiEffect, NODEInMulti, PIXAutoParent {

    public var inputs: [NODE & NODEOut] = [] { didSet { setNeedsConnectMulti(new: inputs, old: oldValue) } }
    
    // MARK: - Life Cycle
    
    public required override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        super.init()
////        fatalError("init(from:) has not been implemented")
//    }
    
    public override func destroy() {
        inputs = []
        super.destroy()
    }
    
}
