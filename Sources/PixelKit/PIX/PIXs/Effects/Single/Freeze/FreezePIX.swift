//
//  FreezePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-23.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import Metal

final public class FreezePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = FreezePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    @LiveBool("freeze") public var freeze: Bool = false {
        didSet {
            canRender = !freeze
        }
    }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_freeze]
    }
    
    override public var values: [Floatable] {
        [freeze]
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
        
        freeze = model.freeze

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.freeze = freeze

        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixFreeze(_ active: Bool) -> FreezePIX {
        let freezePix = FreezePIX()
        freezePix.name = ":freeze:"
        freezePix.input = self as? PIX & NODEOut
        freezePix.freeze = active
        return freezePix
    }
    
}
