//
//  PIXGenerator.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import CoreGraphics
import MetalKit

import RenderKit

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
    
    public var bgColor: PXColor = .black
    public var backgroundColor: PXColor {
        get { bgColor }
        set { bgColor = newValue }
    }
    public var color: PXColor = .white

    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        fatalError("please use init(at:name:typeName:)")
    }
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), name: String, typeName: String) {
        _resolution = resolution
        super.init(name: name, typeName: typeName)
        applyResolution { self.setNeedsRender() }
    }
    
//    required convenience public init(from decoder: Decoder) throws {
//        self.init(resolution: ._128) // CHECK
////        fatalError("init(from:) has not been implemented")
//    }
    
}
