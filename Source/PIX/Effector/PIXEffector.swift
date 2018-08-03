//
//  PIXEffector.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXEffector: PIX, PIXIn, PIXOut {
        
    override init(shader: String) {
        super.init(shader: shader)
        pixInList = []
        pixOutList = []
    }
    
}
