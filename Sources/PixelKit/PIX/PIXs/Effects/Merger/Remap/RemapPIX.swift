//
//  RemapPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution

final public class RemapPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = RemapPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerRemapPIX" }
    
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
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixRemap(pix: () -> (PIX & NODEOut)) -> RemapPIX {
        pixRemap(pix: pix())
    }
    func pixRemap(pix: PIX & NODEOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inputA = self as? PIX & NODEOut
        remapPix.inputB = pix
        return remapPix
    }
    
}
