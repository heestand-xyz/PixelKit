//
//  PIXContent.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit

open class PIXContent: PIX, NODEContent, NODEOutIO {
    
//    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    public var outputPathList: [NODEOutPath] = []
    public var connectedOut: Bool { return !outputPathList.isEmpty }
    
    override public init() {
        super.init()
    }
    
}
