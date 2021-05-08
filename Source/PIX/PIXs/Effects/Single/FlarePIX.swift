//
//  FlarePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//

import CoreGraphics
import RenderKit
import Resolution
import Foundation
import PixelColor

final public class FlarePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleFlarePIX" }
    
    override public var shaderNeedsResolution: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveFloat("scale") public var scale: CGFloat = 0.25
    @LiveInt("count", range: 2...12) public var count: Int = 6
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.25
    @LiveFloat("threshold", range: 0.5...1.0) public var threshold: CGFloat = 0.95
    @LiveFloat("brightness") public var brightness: CGFloat = 1.0
    @LiveFloat("gamma") public var gamma: CGFloat = 0.25
    @LiveColor("color") public var color: PixelColor = .orange
    @LiveInt("rayResolution", range: 8...64) public var rayResolution: Int = 32
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_scale, _count, _angle, _threshold, _brightness, _gamma, _color, _rayResolution]
    }
    
    override public var values: [Floatable] {
        [scale, count, angle, threshold, brightness, gamma, color, rayResolution]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Flare", typeName: "pix-effect-single-flare")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
