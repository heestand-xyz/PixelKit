//
//  FlarePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//

import CoreGraphics
import RenderKit
import Foundation

public class FlarePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleFlarePIX" }
    
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    @Live public var scale: CGFloat = 0.25
    @Live public var count: Int = 6
    @Live public var angle: CGFloat = 0.25
    @Live public var threshold: CGFloat = 0.95
    @Live public var brightness: CGFloat = 1.0
    @Live public var gamma: CGFloat = 0.25
    @Live public var color: PixelColor = .orange
    @Live public var rayRes: Int = 32
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_scale, _count, _angle, _threshold, _brightness, _gamma, _color, _rayRes]
    }
    
    override public var values: [Floatable] {
        [scale, count, angle, threshold, brightness, gamma, color, rayRes]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Flare", typeName: "pix-effect-single-flare")
    }
    
}

public extension NODEOut {
    
    func _flare() -> FlarePIX {
        let flarePix = FlarePIX()
        flarePix.name = ":flare:"
        flarePix.input = self as? PIX & NODEOut
        return flarePix
    }
    
}
