//
//  TransformPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//

public class TransformPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleTransformPIX" }
    // FIXME: shaderAspect
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [position, rotation, scale, size]
    }
      
}

public extension PIXOut {
    
    func _move(by position: LivePoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.position = position
        return transformPix
    }
    
    func _move(x: LiveFloat = 0.0, y: LiveFloat = 0.0) -> TransformPIX {
        return (self as! PIX & PIXOut)._move(by: LivePoint(x: x, y: y))
    }
    
    func _rotatate(by rotation: LiveFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func _rotatate(by360 rotation: LiveFloat) -> TransformPIX {
        return (self as! PIX & PIXOut)._rotatate(by: rotation / 360)
    }
    
    func _rotatate(by2pi rotation: LiveFloat) -> TransformPIX {
        return (self as! PIX & PIXOut)._rotatate(by: rotation / (.pi * 2))
    }
    
    func _scale(by scale: LiveFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.scale = scale
        return transformPix
    }
    
}
