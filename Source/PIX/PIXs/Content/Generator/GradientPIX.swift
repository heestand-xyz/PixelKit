//
//  GradientPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public struct ColorStep {
    public var step: CGFloat
    public var color: PixelColor
    public init(_ step: CGFloat, _ color: PixelColor) {
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
    
    override open var values: [CoreValue] {
        return [scale, offset, position, position] // CHECK
    }
    
    override open var preUniforms: [CGFloat] {
        return [CGFloat(direction.index)]
    }
    override open var postUniforms: [CGFloat] {
        return [CGFloat(extendRamp.index)]
    }

    override public var uniformArray: [[CGFloat]] {
        return colorSteps.map({ colorStep -> [CGFloat] in
            return [colorStep.step, colorStep.color.red, colorStep.color.green, colorStep.color.blue, colorStep.color.alpha]
        })
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(direction.index), scale, offset, position.x, position.y, CGFloat(extendRamp.index)]
    }
    
    // MARK: - Rainbow
    
    public static var rainbowColorSteps: [ColorStep] {
        var colorSteps: [ColorStep] = []
        let count = 7
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1)
            colorSteps.append(ColorStep(fraction, PixelColor(hue: fraction, saturation: 1.0, brightness: 1.0, alpha: 1.0)))
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
    
    func gradientMap(from firstColor: PixelColor, to lastColor: PixelColor) -> LookupPIX {
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
