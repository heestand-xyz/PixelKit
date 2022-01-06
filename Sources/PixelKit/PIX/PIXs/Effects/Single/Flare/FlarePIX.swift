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
    
    public typealias Model = FlarePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleFlarePIX" }
    
    override public var shaderNeedsResolution: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveFloat("scale") public var scale: CGFloat = 0.25
    @LiveInt("count", range: 2...12) public var count: Int = 6
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.25
    @LiveFloat("threshold", range: 0.5...1.0) public var threshold: CGFloat = 0.95
    @LiveFloat("brightness") public var brightness: CGFloat = 1.0
    @LiveFloat("gamma", range: 0.25...1.0, increment: 0.25) public var gamma: CGFloat = 0.25
    @LiveColor("color") public var color: PixelColor = .orange
    @LiveInt("rayResolution", range: 8...64) public var rayResolution: Int = 32
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_scale, _count, _angle, _threshold, _brightness, _gamma, _color, _rayResolution]
    }
    
    override public var values: [Floatable] {
        [scale, count, angle, threshold, brightness, gamma, color, rayResolution]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        scale = model.scale
        count = model.count
        angle = model.angle
        threshold = model.threshold
        brightness = model.brightness
        gamma = model.gamma
        color = model.color
        rayResolution = model.rayResolution

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.scale = scale
        model.count = count
        model.angle = angle
        model.threshold = threshold
        model.brightness = brightness
        model.gamma = gamma
        model.color = color
        model.rayResolution = rayResolution

        super.liveUpdateModelDone()
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
