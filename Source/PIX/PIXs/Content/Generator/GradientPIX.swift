//
//  GradientPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

public struct ColorStop: Floatable {
    public var stop: CGFloat
    public var color: PixelColor
    public init(_ stop: CGFloat, _ color: PixelColor) {
        self.stop = stop
        self.color = color
    }
    public var floats: [CGFloat] {
        [stop, color.red, color.green, color.blue, color.alpha]
    }
    public init(floats: [CGFloat]) {
        guard floats.count == 5 else { self = ColorStop(0.0, .clear); return }
        self = ColorStop(floats[0], PixelColor(red: floats[1], green: floats[2], blue: floats[3], alpha: floats[4]))
    }
}
extension Array: Floatable where Element == ColorStop {
    public var floats: [CGFloat] { flatMap(\.floats) }
    public init(floats: [CGFloat]) {
        guard floats.count % 5 == 0 else { self = []; return }
        let count: Int = floats.count / 5
        var colorStops: [ColorStop] = []
        for i in 0..<count {
            let subFloats: [CGFloat] = Array<CGFloat>(floats[(i * 5)..<((i + 1) * 5)])
            let colorStop: ColorStop = ColorStop(floats: subFloats)
            colorStops.append(colorStop)
        }
        self = colorStops
    }
}

final public class GradientPIX: PIXGenerator, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "contentGeneratorGradientPIX" }
    
    // MARK: - Public Types
    
    public enum Direction: String, Enumable {
        case horizontal
        case vertical
        case radial
        case angle
        public var index: Int {
            switch self {
            case .horizontal: return 0
            case .vertical: return 1
            case .radial: return 2
            case .angle: return 3
            }
        }
        public var name: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            case .radial: return "Radial"
            case .angle: return "Angle"
            }
        }
    }
    
    // MARK: - Public Properties
    
    @LiveEnum("direction") public var direction: Direction = .vertical
    @LiveFloat("scale") public var scale: CGFloat = 1.0
    @LiveFloat("offset", range: -0.5...0.5) public var offset: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveEnum("extendMode") public var extendMode: ExtendMode = .hold
    @Live("colorSteps") public var colorSteps: [ColorStop] = [ColorStop(0.0, .black), ColorStop(1.0, .white)]
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_direction, _scale, _offset, _position, _extendMode, _colorSteps]
    }
    
    override public var values: [Floatable] {
        return [direction, scale, offset, position, position, extendMode]
    }

    override public var uniformArray: [[CGFloat]] {
        colorSteps.map(\.floats)
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(direction.index), scale, offset, position.x, position.y, CGFloat(extendMode.index)]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Gradient", typeName: "pix-content-generator-gradient")
    }
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            direction: Direction = .vertical,
                            colorSteps: [ColorStop] = [ColorStop(0.0, .black), ColorStop(1.0, .white)]) {
        self.init(at: resolution)
        self.direction = direction
        self.colorSteps = colorSteps
    }
    
    // MARK: - Property Funcs
    
    public func pixGradientScale(_ value: CGFloat) -> GradientPIX {
        scale = value
        return self
    }
    
    public func pixGradientOffset(_ value: CGFloat) -> GradientPIX {
        offset = value
        return self
    }
    
    public func pixGradientPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> GradientPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixGradientExtendRamp(_ value: ExtendMode) -> GradientPIX {
        extendMode = value
        return self
    }
    
}

public extension NODEOut {
    
    func pixGradientMap(from firstColor: PixelColor, to lastColor: PixelColor) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = "gradientMap:lookup"
        lookupPix.inputA = self as? PIX & NODEOut
        let resolution: Resolution = PixelKit.main.render.bits == ._8 ? ._256 : ._8192
        let gradientPix = GradientPIX(at: .custom(w: resolution.w, h: 1))
        gradientPix.name = "gradientMap:gradient"
        gradientPix.colorSteps = [ColorStop(0.0, firstColor), ColorStop(1.0, lastColor)]
        lookupPix.inputB = gradientPix
        return lookupPix
    }
    
}
