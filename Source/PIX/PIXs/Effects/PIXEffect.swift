//
//  PIXEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit

open class PIXEffect: PIX, NODEInIO, NODEOutIO {
    
    public var inputList: [NODE & NODEOut] = []
//    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    public var outputPathList: [NODEOutPath] = []
    public var connectedIn: Bool { return !inputList.isEmpty }
    public var connectedOut: Bool { return !outputPathList.isEmpty }
        
    override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
//    }
    
}
