//
//  ClampPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-01.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class ClampPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleClampPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("low", range: 0.0...1.0) public var low: CGFloat = 0.0
    @LiveFloat("high", range: 0.0...1.0) public var high: CGFloat = 1.0
    @LiveBool("clampAlpha") public var clampAlpha: Bool = false
    
    public enum Style: String, Enumable {
        case hold
        case relative
        case loop
        case mirror
        case zero
        public var index: Int {
            switch self {
            case .hold: return 0
            case .loop: return 1
            case .mirror: return 2
            case .zero: return 3
            case .relative: return 4
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .hold: return "Hold"
            case .relative: return "Relative"
            case .loop: return "Loop"
            case .mirror: return "Mirror"
            case .zero: return "Zero"
            }
        }
    }
    @LiveEnum("style") public var style: Style = .hold
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_low, _high, _clampAlpha, _style]
    }
    
    override public var values: [Floatable] {
        [low, high, clampAlpha, style]
    }
        
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Clamp", typeName: "pix-effect-single-clamp")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    func pixClamp(low: CGFloat = 0.0, high: CGFloat = 1.0) -> ClampPIX {
        let clampPix = ClampPIX()
        clampPix.name = ":clamp:"
        clampPix.input = self as? PIX & NODEOut
        clampPix.low = low
        clampPix.high = high
        return clampPix
    }
    
}
