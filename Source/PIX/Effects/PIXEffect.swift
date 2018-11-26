//
//  PIXEffect.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//


open class PIXEffect: PIX, PIXInIO, PIXOutIO {
    
    var pixInList: [PIX & PIXOut] = []
    var pixOutPathList: [PIX.OutPath] = []
    var connectedIn: Bool { return !pixInList.isEmpty }
    var connectedOut: Bool { return !pixOutPathList.isEmpty }
        
    override init() {
        super.init()
        pixInList = []
        pixOutPathList = []
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
//    }
    
}
