//
//  NoisePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-14.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class NoisePIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorNoisePIX" }
    
    // MARK: - Public Properties
    
    public var seed: Int = 0 { didSet { setNeedsRender() } }
    public var octaves: Int = 7 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var zPosition: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var zoom: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var colored: Bool = false { didSet { setNeedsRender() } }
    public var random: Bool = false { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case seed; case octaves; case position; case zPosition; case zoom; case colored; case random
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(seed), CGFloat(octaves), position.x, position.y, zPosition, zoom, colored ? 1 : 0, random ? 1 : 0]
    }
    
//    // MARK: - Life Cycle
//
//    public init(res: Res, seed: Int = Int.random(in: 0...1000), octaves: Int = 7, colored: Bool = false, random: Bool = false) {
//        self.seed = seed
//        self.octaves = octaves
//        self.colored = colored
//        self.random = random
//        super.init(res: res)
//    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
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
        var container = encoder.container(keyedBy: CodingKeys.self)
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
