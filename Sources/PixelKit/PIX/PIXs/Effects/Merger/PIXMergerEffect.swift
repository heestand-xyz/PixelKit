//
//  PIXMergerEffect.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-31.
//  Open Source - MIT License
//

import RenderKit
import Resolution

open class PIXMergerEffect: PIXEffect, NODEMergerEffect, NODEInMerger {
    
    public var mergerEffectModel: PixelMergerEffectModel {
        get { effectModel as! PixelMergerEffectModel }
        set { effectModel = newValue }
    }
    
    public var inputA: (NODE & NODEOut)? { didSet { setNeedsConnectMerger(new: inputA, old: oldValue, second: false) } }
    public var inputB: (NODE & NODEOut)? { didSet { setNeedsConnectMerger(new: inputB, old: oldValue, second: true) } }
    public override var connectedIn: Bool { return inputList.count == 2 }
    
    @LiveEnum("placement") public var placement: Placement = .fit
    
    public override var liveList: [LiveWrap] {
        [_placement]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: PixelMergerEffectModel) {
        super.init(model: model)
    }
    
    public required init() {
        fatalError("please use init(model:)")
    }
    
    public override func destroy() {
        inputA = nil
        inputB = nil
        super.destroy()
    }
    
}
