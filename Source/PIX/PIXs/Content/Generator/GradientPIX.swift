//
//  GradientPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics

public struct ColorStep {
    public var step: LiveFloat
    public var color: LiveColor
    public init(_ step: LiveFloat, _ color: LiveColor) {
        self.step = step
        self.color = color
    }
}

open class GradientPIX: PIXGenerator, PIXAuto {
    
    override open var shaderName: String { return "contentGeneratorGradientPIX" }
    
    // MARK: - Public Types
    
    public enum Direction: String, Codable, CaseIterable {
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
    
    public var direction: Direction = .horizontal { didSet { setNeedsRender() } }
    public var scale: LiveFloat = 1.0
    public var offset: LiveFloat = 0.0
    public var position: LivePoint = .zero
    public var extendRamp: ExtendMode = .hold { didSet { setNeedsRender() } }
    public var colorSteps: [ColorStep] = [ColorStep(0.0, .black), ColorStep(1.0, .white)]
    
    // MARK: - Property Helpers
    
    override open var liveValues: [LiveValue] {
        return [scale, offset, position, position] // CHECK
    }
    
    override open var preUniforms: [CGFloat] {
        return [CGFloat(direction.index)]
    }
    override open var postUniforms: [CGFloat] {
        return [CGFloat(extendRamp.index)]
    }

    override public var liveArray: [[LiveFloat]] {
        return colorSteps.map({ colorStep -> [LiveFloat] in
            return [colorStep.step, colorStep.color.r, colorStep.color.g, colorStep.color.b, colorStep.color.a]
        })
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(direction.index), scale.uniform, offset.uniform, position.x.uniform, position.y.uniform, CGFloat(extendRamp.index)]
    }
    
    // MARK: - Rainbow
    
    public static var rainbowColorSteps: [ColorStep] {
        var colorSteps: [ColorStep] = []
        let count = 7
        for i in 0..<count {
            let fraction = LiveFloat(i) / LiveFloat(count - 1)
            colorSteps.append(ColorStep(fraction, LiveColor(h: fraction, s: 1.0, v: 1.0, a: 1.0)))
        }
        return colorSteps
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Gradient", typeName: "pix-content-generator-gradient")
    }
    
    // MARK: - Rainbow
    
    public func rainbow() {
        colorSteps = GradientPIX.rainbowColorSteps
    }
    
}

public extension NODEOut {
    
    // FIXME: Create custom shader
    func _gradientMap(from firstColor: LiveColor, to lastColor: LiveColor) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = "gradientMap:lookup"
        lookupPix.inputA = self as? PIX & NODEOut
        let resolution: Resolution = PixelKit.main.render.bits == ._8 ? ._256 : ._8192
        let gradientPix = GradientPIX(at: .custom(w: resolution.w, h: 1))
        gradientPix.name = "gradientMap:gradient"
        gradientPix.colorSteps = [ColorStep(0.0, firstColor), ColorStep(1.0, lastColor)]
        lookupPix.inputB = gradientPix
        return lookupPix
    }
    
}
