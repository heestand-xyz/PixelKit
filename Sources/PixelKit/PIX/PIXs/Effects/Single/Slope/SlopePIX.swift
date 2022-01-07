//
//  SlopePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class SlopePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = SlopePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleSlopePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("amplitude", range: 0.0...100.0, increment: 10.0) public var amplitude: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_amplitude]
    }
    
    override public var values: [Floatable] {
        return [amplitude]
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
        
        amplitude = model.amplitude
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.amplitude = amplitude
        
        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixSlope(_ amplitude: CGFloat = 1.0) -> SlopePIX {
        let slopePix = SlopePIX()
        slopePix.name = ":slope:"
        slopePix.input = self as? PIX & NODEOut
        slopePix.amplitude = amplitude
        return slopePix
    }
    
}
