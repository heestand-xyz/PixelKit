//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics

public class BlendPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case blendingMode; case bypassTransform; case position; case rotation; case scale; case size
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index), !bypassTransform.value ? 1 : 0, position.x.cg, position.y.cg, rotation.cg, scale.cg, size.width.cg, size.height.cg]
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        blendingMode = try container.decode(BlendingMode.self, forKey: .blendingMode)
//        bypassTransform = try container.decode(Bool.self, forKey: .bypassTransform)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        rotation = try container.decode(CGFloat.self, forKey: .rotation)
//        scale = try container.decode(CGFloat.self, forKey: .scale)
//        size = try container.decode(CGSize.self, forKey: .size)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(blendingMode, forKey: .blendingMode)
//        try container.encode(bypassTransform, forKey: .bypassTransform)
//        try container.encode(position, forKey: .position)
//        try container.encode(rotation, forKey: .rotation)
//        try container.encode(scale, forKey: .scale)
//        try container.encode(size, forKey: .size)
//    }
    
}

