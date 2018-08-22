//
//  PIXMultiEffect.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class PIXMultiEffect: PIXEffect, PIXInMulti {
    
    public var inPixs: [PIX & PIXOut] = [] { didSet { setNeedsConnect() } }
    
}
