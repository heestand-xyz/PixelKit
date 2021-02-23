//
//  FlarePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//

import CoreGraphics
import RenderKit
import Foundation
import PixelColor

final public class FlarePIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleFlarePIX" }
    
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveFloat(name: "Scale") public var scale: CGFloat = 0.25
    @LiveInt(name: "Count", range: 2...12) public var count: Int = 6
    @LiveFloat(name: "Angle", range: -0.5...0.5) public var angle: CGFloat = 0.25
    @LiveFloat(name: "Threshold", range: 0.5...1.0) public var threshold: CGFloat = 0.95
    @LiveFloat(name: "Brightness") public var brightness: CGFloat = 1.0
    @LiveFloat(name: "Gamma") public var gamma: CGFloat = 0.25
    @LiveColor(name: "Color") public var color: PixelColor = .orange
    @LiveInt(name: "Ray Res", range: 8...64) public var rayRes: Int = 32
    
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
    
    func pixFlare() -> FlarePIX {
        let flarePix = FlarePIX()
        flarePix.name = ":flare:"
        flarePix.input = self as? PIX & NODEOut
        return flarePix
    }
    
}
