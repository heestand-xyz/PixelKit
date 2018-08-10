//
//  PIXEffect.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXEffect: PIX, PIXInIO, PIXOutIO {
    
    var pixInList: [PIX & PIXOut] = []
    var pixOutPathList: [PIX.OutPath] = []
        
    override init() {
        super.init()
        pixInList = []
        pixOutPathList = []
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("PIXEffect Decoder Initializer is not supported.") // CHECK
    }
    
}
