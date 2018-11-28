//
//  GradientPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class GradientPIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorGradientPIX" }
    
    // MARK: - Public Types
    
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
    
    // MARK: - Public Properties
    
    public var style: Style = .horizontal { didSet { setNeedsRender() } }
    public var scale: LiveFloat = 1.0
    public var offset: LiveFloat = 0.0
    public var position: LivePoint = .zero
    public var extendRamp: ExtendMode = .hold { didSet { setNeedsRender() } }
    public var colorSteps: [(LiveFloat, LiveColor)] = [(0.0, .black), (1.0, .white)]
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [scale, offset, position, position]
    }
    
    override var preUniforms: [CGFloat] {
        return [CGFloat(style.index)]
    }
    override var postUniforms: [CGFloat] {
        return [CGFloat(extendRamp.index)]
    }

    override var liveArray: [[LiveFloat]] {
        return colorSteps.map({ fraction, color -> [LiveFloat] in
            return [fraction, color.r, color.g, color.b, color.a]
        })
    }
    
//    enum CodingKeys: String, CodingKey {
//        case style; case scale; case offset; case position; case colorFirst; case colorLast; case extendRamp; case colorSteps
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(style.index), scale.uniform, offset.uniform, position.x.uniform, position.y.uniform, CGFloat(extendRamp.index)]
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init(res: ._128) // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        style = try container.decode(Style.self, forKey: .style)
//        scale = try container.decode(CGFloat.self, forKey: .scale)
//        offset = try container.decode(CGFloat.self, forKey: .offset)
//        position = try container.decode(CGPoint.self, forKey: .position)
//        colorFirst = try container.decode(Color.self, forKey: .colorFirst)
//        colorLast = try container.decode(Color.self, forKey: .colorLast)
//        extendRamp = try container.decode(ExtendMode.self, forKey: .extendRamp)
//        colorSteps = try container.decode(ColorSteps.self, forKey: .colorSteps)
//        setNeedsRender()
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(style, forKey: .style)
//        try container.encode(scale, forKey: .scale)
//        try container.encode(offset, forKey: .offset)
//        try container.encode(position, forKey: .position)
//        try container.encode(colorFirst, forKey: .colorFirst)
//        try container.encode(colorLast, forKey: .colorLast)
//        try container.encode(extendRamp, forKey: .extendRamp)
//        try container.encode(colorSteps, forKey: .colorSteps)
//    }
    
    // MARK: - Rainbow
    
    public static var rainbowColorSteps: [(LiveFloat, LiveColor)] {
        var colorSteps: [(LiveFloat, LiveColor)] = []
        let count = 7
        for i in 0..<count {
            let fraction = LiveFloat(i) / LiveFloat(count - 1)
            colorSteps.append((fraction, LiveColor(h: fraction, s: 1.0, v: 1.0, a: 1.0)))
        }
        return colorSteps
    }
    public func rainbow() {
        colorSteps = GradientPIX.rainbowColorSteps
    }
    
}

public extension PIXOut {
    
    // FIXME: Create custom shader
    func _gradientMap(from firstColor: LiveColor, to lastColor: LiveColor) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = "gradientMap:lookup"
        lookupPix.inPixA = self as? PIX & PIXOut
        let res: PIX.Res = Pixels.main.bits == ._8 ? ._256 : ._8192
        let gradientPix = GradientPIX(res: .custom(w: res.w, h: 1))
        gradientPix.name = "gradientMap:gradient"
        gradientPix.colorSteps = [(0.0, firstColor), (1.0, lastColor)]
        lookupPix.inPixB = gradientPix
        return lookupPix
    }
    
}
