//
//  PIXSingleEffector.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXSingleEffector: PIXEffector, PIXInSingle {
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    
}
