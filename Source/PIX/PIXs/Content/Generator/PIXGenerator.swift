//
//  PIXGenerator.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import LiveValues
import CoreGraphics

open class PIXGenerator: PIXContent, PIXAutoParent, PIXRes {
    
    var _res: Resolution
    public var res: Resolution {
        set { _res = newValue; applyResolution { self.setNeedsRender() } }
        get { return _res * PIXGenerator.globalResMultiplier }
    }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    
    override open var shaderNeedsAspect: Bool { return true }
    
    public static var globalResMultiplier: CGFloat = 1
    
    public var bgColor: LiveColor = .black
    public var color: LiveColor = .white

    public required init(res: Resolution = .auto) {
        _res = res
        super.init()
        applyResolution { self.setNeedsRender() }
    }
    
//    required convenience public init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
////        fatalError("init(from:) has not been implemented")
//    }
    
}
