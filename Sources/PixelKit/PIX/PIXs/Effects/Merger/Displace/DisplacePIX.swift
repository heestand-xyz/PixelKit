//
//  DisplacePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class DisplacePIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = DisplacePixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("distance", range: -1.0...1.0, increment: 0.25) public var distance: CGFloat = 0.25
    @LiveFloat("origin") public var origin: CGFloat = 0.5
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_distance, _origin] + super.liveList
    }
    
    override public var values: [Floatable] {
        [distance, origin, placement]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    public convenience init(distance: CGFloat = 0.1,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.distance = distance
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        distance = model.distance
        origin = model.origin

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.distance = distance
        model.origin = origin

        super.liveUpdateModelDone()
    }
    
    // MARK: - Property Funcs
    
    public func pixDisplaceOrigin(_ value: CGFloat) -> DisplacePIX {
        origin = value
        return self
    }
    
}

public extension NODEOut {

    func pixDisplace(distance: CGFloat, with pix: () -> (PIX & NODEOut)) -> DisplacePIX {
        pixDisplace(pix: pix(), distance: distance)
    }
    func pixDisplace(pix: PIX & NODEOut, distance: CGFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.name = ":displace:"
        displacePix.inputA = self as? PIX & NODEOut
        displacePix.inputB = pix
        displacePix.distance = distance
        return displacePix
    }
    
    func pixNoiseDisplace(distance: CGFloat, motion: CGFloat = 0.0, octaves: Int = 10) -> DisplacePIX {
        let pix = self as! PIX & NODEOut
        let noisePix = NoisePIX(at: pix.finalResolution)
        noisePix.name = "noiseDisplace:noise"
        noisePix.colored = true
        noisePix.motion = motion
        noisePix.octaves = octaves
        return pix.pixDisplace(pix: noisePix, distance: distance)
    }
    
}
