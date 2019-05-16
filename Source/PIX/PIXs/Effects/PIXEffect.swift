//
//  PIXEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//


open class PIXEffect: PIX, PIXInIO, PIXOutIO {
    
    var pixInList: [PIX & PIXOut] = []
    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    var connectedIn: Bool { return !pixInList.isEmpty }
    var connectedOut: Bool { return !pixOutPathList.isEmpty }
        
    override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
//    }
    
}
