//
//  File.swift
//  
//
//  Created by Anton Heestand on 2020-06-01.
//

import Foundation
import RenderKit
import CoreGraphics
import PixelColor

final public class StackPIX: PIXMultiEffect, NODEResolution, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectMultiStackPIX" }
    
    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    
    public enum Axis: String, Enumable {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
        public var index: Int {
            switch self {
            case .horizontal:
                return 0
            case .vertical:
                return 1
            }
        }
        public var names: [String] {
            Self.allCases.map(\.rawValue)
        }
    }
    @LiveEnum(name: "Axis") public var axis: Axis = .vertical
    
    public enum Alignment: String, Enumable {
        case leading = "Leading"
        case center = "Center"
        case trailing = "Trailing"
        public var index: Int {
            switch self {
            case .leading:
                return -1
            case .center:
                return 0
            case .trailing:
                return 1
            }
        }
        public var names: [String] {
            Self.allCases.map(\.rawValue)
        }
    }
    @LiveEnum(name: "Alignment") public var alignment: Alignment = .center
    
    @LiveFloat(name: "Spacing", range: 0.0...0.25) public var spacing: CGFloat = 0.0
    @LiveFloat(name: "Padding", range: 0.0...0.25) public var padding: CGFloat = 0.0
    
    @LiveColor(name: "Background Color") public var backgroundColor: PixelColor = .clear
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_axis, _alignment, _spacing, _padding, _backgroundColor]
    }
    
    public override var values: [Floatable] { [axis, alignment, spacing, padding, backgroundColor] }
        
    public override var extraUniforms: [CGFloat] {
        (0..<10).map { i -> CGFloat in
            guard i < inputs.count else { return 1.0 }
            return inputs[i].finalResolution.aspect
        }
    }
    
    public override var shaderNeedsAspect: Bool { true }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        super.init(name: "Stack", typeName: "pix-effect-multi-stack")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            axis: Axis = .vertical,
                            alignment: Alignment = .center,
                            spacing: CGFloat = 0.0,
                            padding: CGFloat = 0.0,
                            @PIXBuilder inputs: () -> ([PIX & NODEOut]) = { [] }) {
        self.init(at: resolution)
        self.axis = axis
        self.alignment = alignment
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

public func pixVStack(spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    pixVStack(inputs(), spacing: spacing, padding: padding)
}
public func pixVStack(_ inputs: [PIX & NODEOut], spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    pixStack(inputs, axis: .vertical, alignment: .center, spacing: spacing, padding: padding)
}

public func pixHStack(spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    pixHStack(inputs(), spacing: spacing, padding: padding)
}
public func pixHStack(_ inputs: [PIX & NODEOut], spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    pixStack(inputs, axis: .horizontal, alignment: .center, spacing: spacing, padding: padding)
}

public func pixStack(axis: StackPIX.Axis, alignment: StackPIX.Alignment, spacing: CGFloat = 0.0, padding: CGFloat = 0.0, inputs: () -> ([PIX & NODEOut])) -> StackPIX {
    pixStack(inputs(), axis: axis, alignment: alignment, spacing: spacing, padding: padding)
}
public func pixStack(_ inputs: [PIX & NODEOut], axis: StackPIX.Axis, alignment: StackPIX.Alignment, spacing: CGFloat = 0.0, padding: CGFloat = 0.0) -> StackPIX {
    let stackPix = StackPIX()
    stackPix.inputs = inputs
    stackPix.name = ":stack:"
    stackPix.axis = axis
    stackPix.alignment = alignment
    stackPix.spacing = spacing
    stackPix.padding = padding
    return stackPix
}
