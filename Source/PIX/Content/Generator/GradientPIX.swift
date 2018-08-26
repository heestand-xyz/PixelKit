//
//  GradientPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class GradientPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .gradient
    
    override var shader: String { return "contentGeneratorGradientPIX" }
    
    public enum Style: String, Codable {
        case horizontal
        case vertical
        case radial
        case angle
        var index: Int {
            switch self {
            case .horizontal: return 0
            case .vertical: return 1
            case .radial: return 2
            case .angle: return 3
            }
        }
    }
    
    public var style: Style = .horizontal { didSet { setNeedsRender() } }
    public var scale: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var offset: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var colorFirst: UIColor = .black { didSet { setNeedsRender() } }
    public var colorLast: UIColor = .white { didSet { setNeedsRender() } }
    public var extendRamp: ExtendMode = .zero { didSet { setNeedsRender() } }
    public var extraColorsActive: Bool = false { didSet { setNeedsRender() } }
    public var extraColorAActive: Bool = false { didSet { setNeedsRender() } }
    public var extraColorAPosition: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var extraColorA: UIColor = .gray { didSet { setNeedsRender() } }
    public var extraColorBActive: Bool = false { didSet { setNeedsRender() } }
    public var extraColorBPosition: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var extraColorB: UIColor = .gray { didSet { setNeedsRender() } }
    public var extraColorCActive: Bool = false { didSet { setNeedsRender() } }
    public var extraColorCPosition: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var extraColorC: UIColor = .gray { didSet { setNeedsRender() } }
    public var extraColorDActive: Bool = false { didSet { setNeedsRender() } }
    public var extraColorDPosition: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var extraColorD: UIColor = .gray { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case style; case scale; case offset; case colorFirst; case colorLast; case extendRamp
    }
    override var uniforms: [CGFloat] {
        var vals = [CGFloat(style.index), scale, offset]
        vals.append(contentsOf: PIX.Color(colorFirst).list)
        vals.append(contentsOf: PIX.Color(colorLast).list)
        vals.append(CGFloat(extendRamp.index))
        vals.append(extraColorsActive ? 1 : 0)
        vals.append(contentsOf: [extraColorAActive ? 1 : 0, extraColorAPosition])
        vals.append(contentsOf: PIX.Color(extraColorA).list)
        vals.append(contentsOf: [extraColorBActive ? 1 : 0, extraColorBPosition])
        vals.append(contentsOf: PIX.Color(extraColorB).list)
        vals.append(contentsOf: [extraColorCActive ? 1 : 0, extraColorCPosition])
        vals.append(contentsOf: PIX.Color(extraColorC).list)
        vals.append(contentsOf: [extraColorDActive ? 1 : 0, extraColorDPosition])
        vals.append(contentsOf: PIX.Color(extraColorD).list)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        offset = try container.decode(CGFloat.self, forKey: .offset)
        colorFirst = try container.decode(Color.self, forKey: .colorFirst).ui
        colorLast = try container.decode(Color.self, forKey: .colorLast).ui
        extendRamp = try container.decode(ExtendMode.self, forKey: .extendRamp)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encode(scale, forKey: .scale)
        try container.encode(offset, forKey: .offset)
        try container.encode(Color(colorFirst), forKey: .colorFirst)
        try container.encode(Color(colorLast), forKey: .colorLast)
        try container.encode(extendRamp, forKey: .extendRamp)
    }
    
}
