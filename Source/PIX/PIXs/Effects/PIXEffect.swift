//
//  PIXEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import MetalKit
import RenderKit

open class PIXEffect: PIX, NODEInIO, NODEOutIO, NODETileable2D {
    
    public var inputList: [NODE & NODEOut] = []
//    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    public var outputPathList: [NODEOutPath] = []
    public var connectedIn: Bool { return !inputList.isEmpty }
    public var connectedOut: Bool { return !outputPathList.isEmpty }

    public var tileResolution: Resolution { pixelKit.tileResolution }
    public var tileTextures: [[MTLTexture]]?
        
    override init() {
        super.init()
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
//    }
    
}
