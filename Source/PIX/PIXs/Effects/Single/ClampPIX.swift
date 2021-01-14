//
//  ClampPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-01.
//

import CoreGraphics

import RenderKit

public class ClampPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleClampPIX" }
    
    // MARK: - Public Properties
    
    public var low: CGFloat = 0.0
    public var high: CGFloat = 1.0
    public var clampAlpha: Bool = false
    
    public enum Style: String, CaseIterable, Floatable {
        case hold
        case relative
        case loop
        case mirror
        case zero
        var index: Int {
            switch self {
            case .hold: return 0
            case .loop: return 1
            case .mirror: return 2
            case .zero: return 3
            case .relative: return 4
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    public var style: Style = .hold { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [low, high, clampAlpha, style]
    }
        
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Clamp", typeName: "pix-effect-single-clamp")
    }
    
}

public extension NODEOut {
    
    func _clamp(low: CGFloat = 0.0, high: CGFloat = 1.0) -> ClampPIX {
        let clampPix = ClampPIX()
        clampPix.name = ":clamp:"
        clampPix.input = self as? PIX & NODEOut
        clampPix.low = low
        clampPix.high = high
        return clampPix
    }
    
}
