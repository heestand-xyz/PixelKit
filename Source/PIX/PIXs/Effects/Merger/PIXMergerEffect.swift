//
//  PIXMergerEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit

open class PIXMergerEffect: PIXEffect, NODEMergerEffect, NODEInMerger, PIXAutoParent {
    
    public var inputA: (NODE & NODEOut)? { didSet { setNeedsConnectMerger(new: inputA, old: oldValue, second: false) } }
    public var inputB: (NODE & NODEOut)? { didSet { setNeedsConnectMerger(new: inputB, old: oldValue, second: true) } }
    public override var connectedIn: Bool { return inputList.count == 2 }
    
    public var placement: Placement = .aspectFit { didSet { setNeedsRender() } }
    
    // MARK: - Life Cycle
    
    public required init() {
        fatalError("please use init(name:typeName:)")
    }
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
    }
    
    public override func destroy() {
        inputA = nil
        inputB = nil
        super.destroy()
    }
    
}
