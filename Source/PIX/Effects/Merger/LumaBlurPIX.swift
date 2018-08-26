//
//  LumaBlurPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class LumaBlurPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .lumaBlur
    
    override var shader: String { return "effectMergerLumaBlurPIX" }
    
    public enum Style: String, Codable {
        case box
        case angle
        case zoom
        case random
        var index: Int {
            switch self {
            case .box: return 0
            case .angle: return 1
            case .zoom: return 2
            case .random: return 4
            }
        }
    }
    
    public var style: Style = .box { didSet { setNeedsRender() } }
    public var radius: CGFloat = 100 { didSet { setNeedsRender() } }
    public var quality: SampleQualityMode = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case style; case radius; case quality; case angle; case position
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    public override init() {
        super.init()
        extend = .hold
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        quality = try container.decode(SampleQualityMode.self, forKey: .quality)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        position = try container.decode(CGPoint.self, forKey: .position)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encode(radius, forKey: .radius)
        try container.encode(quality, forKey: .quality)
        try container.encode(angle, forKey: .angle)
        try container.encode(position, forKey: .position)
    }
    
}
