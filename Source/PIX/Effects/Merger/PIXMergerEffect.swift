//
//  PIXMergerEffect.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-31.
//  Open Source - MIT License
//
import CoreGraphics//x

open class PIXMergerEffect: PIXEffect, PIXInMerger, PIXAutoParent {
    
    public var inPixA: (PIX & PIXOut)? { didSet { setNeedsConnectMerger(new: inPixA, old: oldValue, second: false) } }
    public var inPixB: (PIX & PIXOut)? { didSet { setNeedsConnectMerger(new: inPixB, old: oldValue, second: true) } }
    override var connectedIn: Bool { return pixInList.count == 2 }
    
    public var placement: Placement = .aspectFit { didSet { setNeedsRender() } }
    
    // MARK: - Life Cycle
    
    public required override init() {
        super.init()
    }
    
}
