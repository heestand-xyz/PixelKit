//
//  PIXOutput.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXOutput: PIX, PIXInIO, PIXInSingle {
    
    var pixInList: [PIX & PIXOut] = []
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    
    override init() {
        super.init()
        pixInList = []
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("PIXOutput Decoder Initializer is not supported.") // CHECK
    }
    
}
