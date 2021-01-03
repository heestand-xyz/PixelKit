//
//  TransformPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-28.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class TransformPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleTransformPIX" }
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero
    public var rotation: CGFloat = 0.0
    public var scale: CGFloat = 1.0
    public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [position, rotation, scale, size]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Transform", typeName: "pix-effect-single-transform")
    }
      
}

public extension NODEOut {
    
    func _move(by position: CGPoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.position = position
        return transformPix
    }
    
    func _move(x: CGFloat = 0.0, y: CGFloat = 0.0) -> TransformPIX {
        return (self as! PIX & NODEOut)._move(by: CGPoint(x: x, y: y))
    }
    
    func _rotatate(by rotation: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func _rotatate(by360 rotation: CGFloat) -> TransformPIX {
        return (self as! PIX & NODEOut)._rotatate(by: rotation / 360)
    }
    
    func _rotatate(by2pi rotation: CGFloat) -> TransformPIX {
        return (self as! PIX & NODEOut)._rotatate(by: rotation / (.pi * 2))
    }
    
    func _scale(by scale: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.scale = scale
        return transformPix
    }
    
    func _scale(size: CGSize) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.size = size
        return transformPix
    }
    
    func _scale(x: CGFloat = 1.0, y: CGFloat = 1.0) -> TransformPIX {
        return _scale(size: CGSize(width: x, height: y))
    }
    
}
