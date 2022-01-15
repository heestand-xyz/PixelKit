//
//  LumaColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-01.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class LumaColorShiftPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = LumaColorShiftPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerLumaColorShiftPIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("hue", range: -0.5...0.5) public var hue: CGFloat = 0.0
    @LiveFloat("saturation", range: 0.0...2.0) public var saturation: CGFloat = 1.0
    @LiveColor("tintColor") public var tintColor: PixelColor = .white
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_hue, _saturation, _tintColor, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [hue, saturation, tintColor, lumaGamma]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    public convenience init(hue: CGFloat = 0.0,
                            saturation: CGFloat = 1.0,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.hue = hue
        self.saturation = saturation
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        hue = model.hue
        saturation = model.saturation
        tintColor = model.tintColor
        lumaGamma = model.lumaGamma

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.hue = hue
        model.saturation = saturation
        model.tintColor = tintColor
        model.lumaGamma = lumaGamma

        super.liveUpdateModelDone()
    }
    
    // MARK: - Property Funcs
    
    public func pixLumaColorShiftTint(color: PixelColor) -> LumaColorShiftPIX {
        tintColor = color
        return self
    }
    
}
