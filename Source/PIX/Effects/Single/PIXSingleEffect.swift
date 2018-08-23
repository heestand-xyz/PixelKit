//
//  PIXSingleEffect.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class PIXSingleEffect: PIXEffect, PIXInSingle {
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    
    public override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
