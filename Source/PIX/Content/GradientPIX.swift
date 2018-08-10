//
//  GradientPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class GradientPIX: PIXContent, PIXable {
    
    var kind: PIX.Kind = .gradient
    
    override var shader: String { return "gradientPIX" }
    override var shaderNeedsAspect: Bool { return true }
    
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
    
    public enum Extend: String, Codable {
        case zero
        case hold
        case repeats
        case mirror
        var index: Int {
            switch self {
            case .zero: return 0
            case .hold: return 1
            case .repeats: return 2
            case .mirror: return 3
            }
        }
    }
    
    public var style: Style = .horizontal { didSet { setNeedsRender() } }
    public var scale: CGFloat = 1 { didSet { setNeedsRender() } }
    public var offset: CGFloat = 0 { didSet { setNeedsRender() } }
    public var colorFirst: UIColor = .black { didSet { setNeedsRender() } }
    public var colorLast: UIColor = .white { didSet { setNeedsRender() } }
    public var extend: Extend = .repeats { didSet { setNeedsRender() } }
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
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    enum GradientCodingKeys: String, CodingKey {
        case style; case scale; case offset; case firstColor; case lastColor; case extend; case premultiply // CHECK Extra Colors...
    }
    override var shaderUniforms: [CGFloat] {
        var uniforms = [CGFloat(style.index), scale, offset]
        uniforms.append(contentsOf: PIX.Color(colorFirst).list)
        uniforms.append(contentsOf: PIX.Color(colorLast).list)
        uniforms.append(CGFloat(extend.index))
        uniforms.append(extraColorsActive ? 1 : 0)
        uniforms.append(contentsOf: [extraColorAActive ? 1 : 0, extraColorAPosition])
        uniforms.append(contentsOf: PIX.Color(extraColorA).list)
        uniforms.append(contentsOf: [extraColorBActive ? 1 : 0, extraColorBPosition])
        uniforms.append(contentsOf: PIX.Color(extraColorB).list)
        uniforms.append(contentsOf: [extraColorCActive ? 1 : 0, extraColorCPosition])
        uniforms.append(contentsOf: PIX.Color(extraColorC).list)
        uniforms.append(contentsOf: [extraColorDActive ? 1 : 0, extraColorDPosition])
        uniforms.append(contentsOf: PIX.Color(extraColorD).list)
        uniforms.append(premultiply ? 1 : 0)
        return uniforms
    }
    
    public init() {
        super.init(res: .auto)
        setNeedsRender()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: GradientCodingKeys.self)
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GradientCodingKeys.self)
        try container.encode(premultiply, forKey: .premultiply)
    }
    
}
