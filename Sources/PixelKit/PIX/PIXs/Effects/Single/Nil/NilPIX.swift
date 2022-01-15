//
//  NilPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-15.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution

final public class NilPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = NilPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    var nilOverrideBits: Bits?
    public override var overrideBits: Bits? { nilOverrideBits }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    public init(overrideBits: Bits) {
        nilOverrideBits = overrideBits
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    /// bypass is `false` by *default*
    func pixNil(bypass: Bool = false) -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.input = self as? PIX & NODEOut
        nilPix.bypass = bypass
        return nilPix
    }
    
}
