//
//  TransformPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//

public class TransformPIX: PIXSingleEffect {
    
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
    
//    enum CodingKeys: String, CodingKey {
//        case position; case rotation; case scale; case size
//    }
//    open override var uniforms: [CGFloat] {
//        return [position.x, position.y, rotation, scale, size.width, size.height]
//    }
      
}

public extension PIXOut {
    
    func _position(at position: LivePoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.position = position
        return transformPix
    }
    
    func _rotatate(to rotation: LiveFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func _scale(by scale: LiveFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.scale = scale
        return transformPix
    }
    
}
