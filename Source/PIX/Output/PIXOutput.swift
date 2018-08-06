//
//  PIXOutput.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXOutput: PIX, PIXInSingle {
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    
    override init() {
        super.init()
        pixInList = []
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("PIXOutput Decoder Initializer is not supported.") // CHECK
    }
    
}
