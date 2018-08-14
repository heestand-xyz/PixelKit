//
//  NoisePIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-14.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class NoisePIX: PIXContent, PIXable {
    
    var kind: PIX.Kind = .noise
    
    override var shader: String { return "noisePIX" }
    override var shaderNeedsAspect: Bool { return true }
    
    public var seed: Int = 0 { didSet { setNeedsRender() } }
    public var octaves: Int = 7 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var zPosition: CGFloat = 0 { didSet { setNeedsRender() } }
    public var zoom: CGFloat = 1 { didSet { setNeedsRender() } }
    public var colored: Bool = false { didSet { setNeedsRender() } }
    public var random: Bool = false { didSet { setNeedsRender() } }
    enum NoiseCodingKeys: String, CodingKey {
        case seed; case octaves; case position; case zPosition; case zoom; case colored; case random
    }
    override var shaderUniforms: [CGFloat] {
        return [CGFloat(seed), CGFloat(octaves), position.x, position.y, zPosition, zoom, colored ? 1 : 0, random ? 1 : 0]
    }
    
    public init() {
        super.init(res: .auto)
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: NoiseCodingKeys.self)
        seed = try container.decode(Int.self, forKey: .seed)
        octaves = try container.decode(Int.self, forKey: .octaves)
        position = try container.decode(CGPoint.self, forKey: .position)
        zPosition = try container.decode(CGFloat.self, forKey: .zPosition)
        zoom = try container.decode(CGFloat.self, forKey: .zoom)
        colored = try container.decode(Bool.self, forKey: .colored)
        random = try container.decode(Bool.self, forKey: .random)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NoiseCodingKeys.self)
        try container.encode(seed, forKey: .seed)
        try container.encode(octaves, forKey: .octaves)
        try container.encode(position, forKey: .position)
        try container.encode(zPosition, forKey: .zPosition)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(colored, forKey: .colored)
        try container.encode(random, forKey: .random)
        try container.encode(seed, forKey: .seed)
    }
    
}
