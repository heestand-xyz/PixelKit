//
//  PIXGenerator.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics

open class PIXGenerator: PIXContent, NODEGenerator, NODEResolution, NODETileable2D, PIXAutoParent {
    
    var _resolution: Resolution
    public var resolution: Resolution {
        set { _resolution = newValue; applyResolution { self.setNeedsRender() } }
        get { return _resolution * PIXGenerator.globalResMultiplier }
    }
    public static var globalResMultiplier: CGFloat = 1
    
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    override open var shaderNeedsAspect: Bool { return true }
    
    public var tileResolution: Resolution { pixelKit.tileResolution }
    public var tileTextures: [[MTLTexture]]?
    
    public var bgColor: LiveColor = .black
    public var color: LiveColor = .white

    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        _resolution = resolution
        super.init()
        applyResolution { self.setNeedsRender() }
    }
    
//    required convenience public init(from decoder: Decoder) throws {
//        self.init(resolution: ._128) // CHECK
////        fatalError("init(from:) has not been implemented")
//    }
    
}
