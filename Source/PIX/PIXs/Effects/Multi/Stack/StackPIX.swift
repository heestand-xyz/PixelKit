//
//  File.swift
//  
//
//  Created by Anton Heestand on 2020-06-01.
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class StackPIX: PIXMultiEffect, NODEResolution, PIXViewable {
    
    override public var shaderName: String { return "effectMultiStackPIX" }
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    public enum Axis: String, Enumable {
        case horizontal
        case vertical
        public var index: Int {
            switch self {
            case .horizontal:
                return 0
            case .vertical:
                return 1
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .horizontal:
                return "Horizontal"
            case .vertical:
                return "Vertical"
            }
        }
    }
    @LiveEnum("axis") public var axis: Axis = .vertical
    
    public enum Alignment: String, Enumable {
        case leading
        case center
        case trailing
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
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .leading:
                return "Leading"
            case .center:
                return "Center"
            case .trailing:
                return "Trailing"
            }
        }
    }
    @LiveEnum("alignment") public var alignment: Alignment = .center
    
    @LiveFloat("spacing", range: 0.0...0.25, increment: 0.05) public var spacing: CGFloat = 0.0
    @LiveFloat("padding", range: 0.0...0.25, increment: 0.05) public var padding: CGFloat = 0.0
    
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .clear
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_axis, _alignment, _spacing, _padding, _backgroundColor, _resolution] + super.liveList
    }
    
    public override var values: [Floatable] { [axis, alignment, spacing, padding, backgroundColor] }
        
    public override var extraUniforms: [CGFloat] {
        (0..<10).map { i -> CGFloat in
            guard i < inputs.count else { return 1.0 }
            return inputs[i].finalResolution.aspect
        }
    }
    
    public override var shaderNeedsResolution: Bool { true }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        super.init(name: "Stack", typeName: "pix-effect-multi-stack")
    }
    
    #if swift(>=5.5)
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
    #endif
    
    public required convenience init() {
        self.init(at: .auto(render: PixelKit.main.render))
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
