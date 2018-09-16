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
    
    override open var shader: String { return "contentGeneratorGradientPIX" }
    
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
    
    public struct ColorStep: Codable {
        public let color: Color
        public let fraction: CGFloat
        public init(_ color: UIColor, at fraction: CGFloat) {
            self.color = Color(color)
            self.fraction = fraction
        }
    }
    
    public struct ColorSteps: Codable {
        public let a: ColorStep?
        public let b: ColorStep?
        public let c: ColorStep?
        public let d: ColorStep?
        public init(_ a: ColorStep, _ b: ColorStep? = nil, _ c: ColorStep? = nil, _ d: ColorStep? = nil) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
    }
    
    public var style: Style = .horizontal { didSet { setNeedsRender() } }
    public var scale: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var offset: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var colorFirst: UIColor = .black { didSet { setNeedsRender() } }
    public var colorLast: UIColor = .white { didSet { setNeedsRender() } }
    public var extendRamp: ExtendMode = .zero { didSet { setNeedsRender() } }
    public var colorSteps: ColorSteps? { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case style; case scale; case offset; case colorFirst; case colorLast; case extendRamp; case colorSteps
    }
    override var uniforms: [CGFloat] {
        var vals = [CGFloat(style.index), scale, offset]
        vals.append(contentsOf: PIX.Color(colorFirst).list)
        vals.append(contentsOf: PIX.Color(colorLast).list)
        vals.append(CGFloat(extendRamp.index))
        vals.append(colorSteps != nil ? 1 : 0)
        vals.append(contentsOf: [colorSteps?.a != nil ? 1 : 0, colorSteps?.a?.fraction ?? 0])
        vals.append(contentsOf: colorSteps?.a?.color.list ?? [0,0,0,0])
        vals.append(contentsOf: [colorSteps?.b != nil ? 1 : 0, colorSteps?.b?.fraction ?? 0])
        vals.append(contentsOf: colorSteps?.b?.color.list ?? [0,0,0,0])
        vals.append(contentsOf: [colorSteps?.c != nil ? 1 : 0, colorSteps?.c?.fraction ?? 0])
        vals.append(contentsOf: colorSteps?.c?.color.list ?? [0,0,0,0])
        vals.append(contentsOf: [colorSteps?.d != nil ? 1 : 0, colorSteps?.d?.fraction ?? 0])
        vals.append(contentsOf: colorSteps?.d?.color.list ?? [0,0,0,0])
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
        colorSteps = try container.decode(ColorSteps.self, forKey: .colorSteps)
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
        try container.encode(colorSteps, forKey: .colorSteps)
    }
    
}
