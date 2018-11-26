//
//  PIXGenerator.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

open class PIXGenerator: PIXContent {
    
    var _res: Res
    public var res: Res {
        set { _res = newValue; applyRes { self.setNeedsRender() } }
        get { return _res * PIXGenerator.globalResMultiplier }
    }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    public static var globalResMultiplier: CGFloat = 1
    
    public init(res: Res) {
        _res = res
        super.init()
        applyRes { self.setNeedsRender() }
    }
    
//    required convenience public init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
////        fatalError("init(from:) has not been implemented")
//    }
    
}
