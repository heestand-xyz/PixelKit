//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class BlendPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .blend
    
    override var shader: String { return "effectMergerBlendPIX" }
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: Bool = false { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var rotation: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var scale: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var size: CGSize = CGSize(width: 1.0, height: 1.0) { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case blendingMode; case bypassTransform; case position; case rotation; case scale; case size
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index), !bypassTransform ? 1 : 0, position.x, position.y, rotation, scale, size.width, size.height]
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blendingMode = try container.decode(BlendingMode.self, forKey: .blendingMode)
        bypassTransform = try container.decode(Bool.self, forKey: .bypassTransform)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        size = try container.decode(CGSize.self, forKey: .size)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blendingMode, forKey: .blendingMode)
        try container.encode(bypassTransform, forKey: .bypassTransform)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(scale, forKey: .scale)
        try container.encode(size, forKey: .size)
    }
    
}

