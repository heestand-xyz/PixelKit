//
//  PIXGenerator.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import CoreGraphics

open class PIXGenerator: PIXContent, PIXAutoParent {
    
    var _res: Res
    public var res: Res {
        set { _res = newValue; applyRes { self.setNeedsRender() } }
        get { return _res * PIXGenerator.globalResMultiplier }
    }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    public static var globalResMultiplier: CGFloat = 1
    
    public var bgColor: LiveColor = .black
    public var color: LiveColor = .white

    public required init(res: Res) {
        _res = res
        super.init()
        applyRes { self.setNeedsRender() }
    }
    
//    required convenience public init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
////        fatalError("init(from:) has not been implemented")
//    }
    
}
