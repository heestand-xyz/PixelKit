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
    
    @Live public var position: CGPoint = .zero
    @Live public var rotation: CGFloat = 0.0
    @Live public var scale: CGFloat = 1.0
    @Live public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_position, _rotation, _scale, _size]
    }
    
    override public var values: [Floatable] {
        return [position, rotation, scale, size]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Transform", typeName: "pix-effect-single-transform")
    }
      
}

public extension NODEOut {
    
    @available(*, deprecated, renamed: "translate(by:)")
    func move(by position: CGPoint) -> TransformPIX {
        translate(by: position)
    }
    func translate(by position: CGPoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.position = position
        return transformPix
    }
    
    @available(*, deprecated, renamed: "translate(x:y:)")
    func move(x: CGFloat = 0.0, y: CGFloat = 0.0) -> TransformPIX {
        return (self as! PIX & NODEOut).move(by: CGPoint(x: x, y: y))
    }
    func translate(x: CGFloat = 0.0, y: CGFloat = 0.0) -> TransformPIX {
        return (self as! PIX & NODEOut).translate(by: CGPoint(x: x, y: y))
    }
    
    func rotatate(by rotation: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func rotatate(by360 rotation: CGFloat) -> TransformPIX {
        return (self as! PIX & NODEOut).rotatate(by: rotation / 360)
    }
    
    func rotatate(by2pi rotation: CGFloat) -> TransformPIX {
        return (self as! PIX & NODEOut).rotatate(by: rotation / (.pi * 2))
    }
    
    func scale(by scale: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.scale = scale
        return transformPix
    }
    
    @available(*, deprecated, renamed: "resize(by:)")
    func scale(size: CGSize) -> TransformPIX {
        resize(by: size)
    }
    func resize(by size: CGSize) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.size = size
        return transformPix
    }
    
    func scale(x: CGFloat = 1.0, y: CGFloat = 1.0) -> TransformPIX {
        return resize(by: CGSize(width: x, height: y))
    }
    
}
