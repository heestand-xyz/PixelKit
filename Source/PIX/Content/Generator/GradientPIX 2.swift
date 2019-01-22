//
//  GradientPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class GradientPIX: PIXGenerator, PIXofaKind {
    
    var kind: PIX.Kind = .gradient
    
    override open var shader: String { return "contentGeneratorGradientPIX" }
    
    // MARK: - Public Properties
    
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
        public var color: Color
        public var fraction: CGFloat
        public init(_ color: Color, at fraction: CGFloat) {
            self.color = color
            self.fraction = fraction
        }
    }
    
    public struct ColorSteps: Codable {
        public var a: ColorStep?
        public var b: ColorStep?
        public var c: ColorStep?
        public var d: ColorStep?
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
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    public var colorFirst: Color = .black { didSet { setNeedsRender() } }
    public var colorLast: Color = .white { didSet { setNeedsRender() } }
    public var extendRamp: ExtendMode = .hold { didSet { setNeedsRender() } }
    public var colorSteps: ColorSteps? { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case style; case scale; case offset; case position; case colorFirst; case colorLast; case extendRamp; case colorSteps
    }
    
    open override var uniforms: [CGFloat] {
        var vals = [CGFloat(style.index), scale, offset, position.x, position.y]
        vals.append(contentsOf: colorFirst.list)
        vals.append(contentsOf: colorLast.list)
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
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        offset = try container.decode(CGFloat.self, forKey: .offset)
        position = try container.decode(CGPoint.self, forKey: .position)
        colorFirst = try container.decode(Color.self, forKey: .colorFirst)
        colorLast = try container.decode(Color.self, forKey: .colorLast)
        extendRamp = try container.decode(ExtendMode.self, forKey: .extendRamp)
        colorSteps = try container.decode(ColorSteps.self, forKey: .colorSteps)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encode(scale, forKey: .scale)
        try container.encode(offset, forKey: .offset)
        try container.encode(position, forKey: .position)
        try container.encode(colorFirst, forKey: .colorFirst)
        try container.encode(colorLast, forKey: .colorLast)
        try container.encode(extendRamp, forKey: .extendRamp)
        try container.encode(colorSteps, forKey: .colorSteps)
    }
    
}

public extension PIXOut {
    
    // FIXME: Create custom shader
    func _gradientMap(from colorFirst: PIX.Color, to colorLast: PIX.Color) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = "gradientMap:lookup"
        lookupPix.inPixA = self as? PIX & PIXOut
        let res: PIX.Res = Pixels.main.colorBits == ._8 ? ._256 : ._8192
        let gradientPix = GradientPIX(res: .custom(w: res.w, h: 1))
        gradientPix.name = "gradientMap:gradient"
        gradientPix.colorFirst = colorFirst
        gradientPix.colorLast = colorLast
        lookupPix.inPixB = gradientPix
        return lookupPix
    }
    
}
