//
//  PIXOutput.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//


open class PIXOutput: PIX, PIXInIO, PIXInSingle {
    
    var pixInList: [PIX & PIXOut] = []
    var connectedIn: Bool { return !pixInList.isEmpty }
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    
    open override var shader: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    override init() {
        super.init()
        pixInList = []
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("PIXOutput Decoder Initializer is not supported.") // CHECK
    }
    
}
