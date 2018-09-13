//
//  PIXContent.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

open class PIXContent: PIX, PIXOutIO {
    
    var pixOutPathList: [PIX.OutPath] = []
    var connectedOut: Bool { return !pixOutPathList.isEmpty }
    
    override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("PIXContent Decoder Initializer is not supported.") // CHECK
    }
    
}
