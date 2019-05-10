//
//  PIXSingleEffect.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//


open class PIXSingleEffect: PIXEffect, PIXInSingle, PIXAutoParent {
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnectSingle(new: inPix, old: oldValue) } }
    
    // MARK: - Life Cycle
    
    public required override init() {
        super.init()
    }
    
    public override func destroy() {
        inPix = nil
        super.destroy()
    }
    
}
