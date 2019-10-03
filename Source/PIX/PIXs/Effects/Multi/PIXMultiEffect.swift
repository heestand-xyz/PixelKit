//
//  PIXMultiEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//


open class PIXMultiEffect: PIXEffect, NODEInMulti, PIXAutoParent {
    
    public var inPixs: [PIX & NODEOut] = [] { didSet { setNeedsConnectMulti(new: inPixs, old: oldValue) } }
    
    // MARK: - Life Cycle
    
    public required override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        super.init()
////        fatalError("init(from:) has not been implemented")
//    }
    
    public override func destroy() {
        inPixs = []
        super.destroy()
    }
    
}
