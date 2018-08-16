//
//  PIXGenerator.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXGenerator: PIXContent {
    
    var _res: Res? = nil
    public var res: Res? {
        set { _res = newValue; applyRes { self.setNeedsRender() } }
        get { return _res != nil ? _res! * PIXGenerator.globalResMultiplier : nil }
    }
    
    public static var globalResMultiplier: CGFloat = 1
    
    public init(res: Res) {
        super.init()
        self.res = res
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
