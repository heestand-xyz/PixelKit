//
//  PIXSingleEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit

open class PIXSingleEffect: PIXEffect, NODESingleEffect, NODEInSingle, PIXAutoParent {
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    // MARK: - Life Cycle
    
    public required override init() {
        super.init()
    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
}
