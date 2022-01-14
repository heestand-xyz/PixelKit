//
//  BlendsPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-14.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class BlendsPIX: PIXMultiEffect, PIXViewable {
    
    public typealias Model = BlendsPixelModel
    
    private var model: Model {
        get { multiEffectModel as! Model }
        set { multiEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMultiBlendsPIX" }
    
    // MARK: - Public Properties
    
    @LiveEnum("blendMode") public var blendMode: BlendMode = .add
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_blendMode]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(blendMode.index)]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    #if swift(>=5.5)
    public convenience init(blendMode: BlendMode = .add,
                            @PIXBuilder inputs: () -> ([PIX & NODEOut]) = { [] }) {
        self.init()
        self.blendMode = blendMode
        super.inputs = inputs()
    }
    #endif
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        blendMode = model.blendMode

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.blendMode = blendMode

        super.liveUpdateModelDone()
    }
    
}

// MARK: - Loop

public func pixLoop(_ count: Int, blendMode: BlendMode, extend: ExtendMode = .zero, loop: (Int, CGFloat) -> (PIX & NODEOut)) -> BlendsPIX {
    let blendsPix = BlendsPIX()
    blendsPix.name = "loop:blends"
    blendsPix.blendMode = blendMode
    blendsPix.extend = extend
    for i in 0..<count {
        let fraction = CGFloat(i) / CGFloat(count)
        let pix = loop(i, fraction)
        pix.name = "\(pix.name):\(i)"
        blendsPix.inputs.append(pix)
    }
    return blendsPix
}
