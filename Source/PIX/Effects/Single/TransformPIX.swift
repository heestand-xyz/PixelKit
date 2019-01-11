//
//  TransformPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//
import CoreGraphics//x

public class TransformPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleTransformPIX" }
    // FIXME: shaderAspect
    
    // MARK: - Public Properties
    
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var rotation: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var scale: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var size: CGSize = CGSize(width: 1.0, height: 1.0) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case position; case rotation; case scale; case size
//    }
    open override var uniforms: [CGFloat] {
        return [position.x, position.y, rotation, scale, size.width, size.height]
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        rotation = try container.decode(CGFloat.self, forKey: .rotation)
//        scale = try container.decode(CGFloat.self, forKey: .scale)
//        size = try container.decode(CGSize.self, forKey: .size)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(position, forKey: .position)
//        try container.encode(rotation, forKey: .rotation)
//        try container.encode(scale, forKey: .scale)
//        try container.encode(size, forKey: .size)
//    }
    
}

public extension PIXOut {
    
    func _position(at position: CGPoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.position = position
        return transformPix
    }
    
    func _rotatate(to rotation: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func _scale(by scale: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.inPix = self as? PIX & PIXOut
        transformPix.scale = scale
        return transformPix
    }
    
}
