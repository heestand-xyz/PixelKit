//
//  TwirlPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-11.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class TwirlPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = TwirlPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleTwirlPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("strength", range: 0.0...5.0, increment: 1.0) public var strength: CGFloat = 2.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_strength]
    }
    
    override public var values: [Floatable] {
        [strength]
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
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        strength = model.strength

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.strength = strength

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixTwirl(_ strength: CGFloat) -> TwirlPIX {
        let twirlPix = TwirlPIX()
        twirlPix.name = ":twirl:"
        twirlPix.input = self as? PIX & NODEOut
        twirlPix.strength = strength
        return twirlPix
    }
    
}
