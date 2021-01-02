//
//  GradientPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public struct ColorStep {
    public var step: CGFloat
    public var color: PXColor
    public init(_ step: CGFloat, _ color: PXColor) {
        self.step = step
        self.color = color
    }
}

open class GradientPIX: PIXGenerator {
    
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
    public var scale: CGFloat = 1.0
    public var offset: CGFloat = 0.0
    public var position: CGPoint = .zero
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

    override public var liveArray: [[CGFloat]] {
        return colorSteps.map({ colorStep -> [CGFloat] in
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
            let fraction = CGFloat(i) / CGFloat(count - 1)
            colorSteps.append(ColorStep(fraction, PXColor(h: fraction, s: 1.0, v: 1.0, a: 1.0)))
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
    func _gradientMap(from firstColor: PXColor, to lastColor: PXColor) -> LookupPIX {
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
