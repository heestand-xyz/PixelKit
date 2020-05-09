//
//  ClampPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics
import LiveValues
import RenderKit

public class ClampPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleClampPIX" }
    
    // MARK: - Public Properties
    
    public var low: LiveFloat = 0.0
    public var high: LiveFloat = 1.0
    public var clampAlpha: LiveBool = false
    
    public enum Style: String, CaseIterable {
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
    }
    public var style: Style = .hold { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [low, high, clampAlpha]
    }
    
    public override var postUniforms: [CGFloat] { [CGFloat(style.index)] }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Clamp", typeName: "pix-effect-single-clamp")
    }
    
}

public extension NODEOut {
    
    func _clamp(low: LiveFloat = 0.0, high: LiveFloat = 1.0) -> ClampPIX {
        let clampPix = ClampPIX()
        clampPix.name = ":clamp:"
        clampPix.input = self as? PIX & NODEOut
        clampPix.low = low
        clampPix.high = high
        return clampPix
    }
    
}
