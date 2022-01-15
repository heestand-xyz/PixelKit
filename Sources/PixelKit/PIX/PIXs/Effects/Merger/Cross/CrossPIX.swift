//
//  CrossPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-21.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class CrossPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = CrossPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerCrossPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("fraction", increment: 0.5) public var fraction: CGFloat = 0.5
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_fraction] + super.liveList
    }
    
    override public var values: [Floatable] {
        [fraction]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    public convenience init(fraction: CGFloat = 0.5,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.fraction = fraction
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        fraction = model.fraction

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.fraction = fraction

        super.liveUpdateModelDone()
    }
    
}

//public extension NODEOut {
//    
//    func cross(with pix: PIX & NODEOut, fraction: CGFloat) -> CrossPIX {
//        let crossPix = CrossPIX()
//        crossPix.name = ":cross:"
//        crossPix.inputA = self as? PIX & NODEOut
//        crossPix.inputB = pix
//        crossPix.fraction = fraction
//        return crossPix
//    }
//    
//}

public func pixCross(_ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut, at fraction: CGFloat = 0.5) -> CrossPIX {
    let crossPix = CrossPIX()
    crossPix.name = ":cross:"
    crossPix.inputA = pixA
    crossPix.inputB = pixB
    crossPix.fraction = fraction
    return crossPix
}
