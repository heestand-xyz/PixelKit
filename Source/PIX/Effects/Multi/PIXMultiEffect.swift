//
//  PIXMultiEffect.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//


open class PIXMultiEffect: PIXEffect, PIXInMulti {
    
    public var inPixs: [PIX & PIXOut] = [] { didSet { setNeedsConnect() } }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
//        fatalError("init(from:) has not been implemented")
    }
    
}
