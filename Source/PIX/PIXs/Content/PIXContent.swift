//
//  PIXContent.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//


open class PIXContent: PIX, PIXOutIO {
    
//    var pixOutPathList: PIX.WeakOutPaths = PIX.WeakOutPaths([])
    public var pixOutPathList: [PIX.OutPath] = []
    public var connectedOut: Bool { return !pixOutPathList.isEmpty }
    
    override public init() {
        super.init()
    }
    
}
