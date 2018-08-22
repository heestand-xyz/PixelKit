//
//  PIXGenerator.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class PIXGenerator: PIXContent {
    
    var _res: Res
    public var res: Res {
        set { _res = newValue; applyRes { self.setNeedsRender() } }
        get { return _res /* * PIXGenerator.globalResMultiplier */ }
    }
    
    public static var globalResMultiplier: CGFloat = 1
    
    public init(res: Res) {
        _res = res
        super.init()
        applyRes { self.setNeedsRender() }
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
