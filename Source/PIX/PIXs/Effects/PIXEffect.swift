//
//  PIXEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//


open class PIXEffect: PIX, NODEInIO, NODEOutIO {
    
    public var pixInList: [PIX & NODEOut] = []
//    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    public var pixOutPathList: [PIX.OutPath] = []
    public var connectedIn: Bool { return !pixInList.isEmpty }
    public var connectedOut: Bool { return !pixOutPathList.isEmpty }
        
    override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
//    }
    
}
