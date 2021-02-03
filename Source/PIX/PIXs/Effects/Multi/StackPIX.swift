//
//  File.swift
//  
//
//  Created by Anton Heestand on 2020-06-01.
//

import RenderKit
import CoreGraphics
import PixelColor

final public class StackPIX: PIXMultiEffect, NODEResolution, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectMultiStackPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    
    public enum Axis: Floatable {
        public enum VerticalAlignment: Int {
            case bottom = -1
            case center = 0
            case top = 1
        }
        case horizontal(alignment: VerticalAlignment = .center)
        public enum HorizontalAlignment: Int {
            case left = -1
            case center = 0
            case right = 1
        }
        case vertical(alignment: HorizontalAlignment = .center)
        public init?(index: Int, alignmentIndex: Int) {
            switch index {
            case 0:
                guard let alignment = VerticalAlignment(rawValue: alignmentIndex) else { return nil }
                self = .horizontal(alignment: alignment)
            case 1:
                guard let alignment = HorizontalAlignment(rawValue: alignmentIndex) else { return nil }
                self = .vertical(alignment: alignment)
            default:
                return nil
            }
        }
        public var index: Int {
            switch self {
            case .horizontal:
                return 0
            case .vertical:
                return 1
            }
        }
        public var alignmentIndex: Int {
            switch self {
            case .horizontal(alignment: let alignment):
                return alignment.rawValue
            case .vertical(alignment: let alignment):
                return alignment.rawValue
            }
        }
        public var floats: [CGFloat] { [CGFloat(index), CGFloat(alignmentIndex)] }
    }
    @Live public var axis: Axis = .vertical(alignment: .center)
    
    @Live public var spacing: CGFloat = 0.0
    @Live public var padding: CGFloat = 0.0
    
    @Live public var backgroundColor: PixelColor = .clear
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_axis, _spacing, _padding, _backgroundColor]
    }
    
    public override var values: [Floatable] { [axis, spacing, padding, backgroundColor] }
        
    public override var extraUniforms: [CGFloat] {
        (0..<10).map { i -> CGFloat in
            guard i < inputs.count else { return 1.0 }
            return inputs[i].renderResolution.aspect
        }
    }
    
    public override var shaderNeedsAspect: Bool { true }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        super.init(name: "Stack", typeName: "pix-effect-multi-stack")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            axis: Axis = .vertical(alignment: .center),
                            spacing: CGFloat = 0.0,
                            padding: CGFloat = 0.0,
                            @PIXBuilder inputs: () -> ([PIX & NODEOut]) = { [] }) {
        self.init(at: resolution)
        self.axis = axis
        self.spacing = spacing
        self.padding = padding
        super.inputs = inputs()
    }
    
    public required init() {
        fatalError("Please create StackPIX with a Resolution")
    }
    
    // MARK: - Property Funcs
    
    public func pixResolution(_ value: Resolution) -> Self {
        resolution = value
        return self
    }
    
    public func pixBackgroundColor(_ value: PixelColor) -> Self {
        backgroundColor = value
        return self
    }
    
}

// MARK: - Stack

public func vStack(spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    vStack(inputs(), spacing: spacing, padding: padding)
}
public func vStack(_ inputs: [PIX & NODEOut], spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    stack(inputs, axis: .vertical(alignment: .center), spacing: spacing, padding: padding)
}

public func hStack(spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    hStack(inputs(), spacing: spacing, padding: padding)
}
public func hStack(_ inputs: [PIX & NODEOut], spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    stack(inputs, axis: .horizontal(alignment: .center), spacing: spacing, padding: padding)
}

public func stack(axis: StackPIX.Axis, spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    stack(inputs(), axis: axis, spacing: spacing, padding: padding)
}
public func stack(_ inputs: [PIX & NODEOut], axis: StackPIX.Axis, spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    let stackPix = StackPIX()
    stackPix.inputs = inputs
    stackPix.name = ":stack:"
    stackPix.axis = axis
    stackPix.spacing = spacing
    stackPix.padding = padding
    return stackPix
}
