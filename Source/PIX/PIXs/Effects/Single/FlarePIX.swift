//
//  FlarePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//


import RenderKit
import Foundation

public class FlarePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleFlarePIX" }
    
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var scale: CGFloat = 0.25
    public var count: Int = 6
    public var angle: CGFloat = 0.25
    public var threshold: CGFloat = 0.95
    public var brightness: CGFloat = 1.0
    public var gamma: CGFloat = 0.25
    public var color: PixelColor = .orange
    public var rayRes: Int = 32
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [scale, count, angle, threshold, brightness, gamma, color, rayRes]
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
