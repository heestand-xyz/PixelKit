//
//  ColorShiftPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-04.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

@available(*, deprecated, renamed: "ColorShiftPIX")
public typealias HueSaturationPIX = ColorShiftPIX

final public class ColorShiftPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = ColorShiftPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleColorShiftPIX" }
    
    // MARK: - Public Properties

    @LiveFloat("hue", range: -0.5...0.5) public var hue: CGFloat = 0.0
    @LiveFloat("saturation", range: 0.0...2.0) public var saturation: CGFloat = 1.0
    @LiveColor("tintColor") public var tintColor: PixelColor = .white
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_hue, _saturation, _tintColor]
    }
    
    override public var values: [Floatable] {
        return [hue, saturation, tintColor]
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
        
        hue = model.hue
        saturation = model.saturation
        tintColor = model.tintColor
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.hue = hue
        model.saturation = saturation
        model.tintColor = tintColor
        
        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixTint(_ tintColor: PixelColor) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "tint:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.tintColor = tintColor
        return colorShiftPix
    }
    
    func pixHue(_ hue: CGFloat) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "hue:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.hue = hue
        return colorShiftPix
    }
    
    func pixSaturation(_ saturation: CGFloat) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "saturation:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.saturation = saturation
        return colorShiftPix
    }
    
    func pixMonochrome(_ tintColor: PixelColor = .white) -> ColorShiftPIX {
        let colorShiftPix = ColorShiftPIX()
        colorShiftPix.name = "monochrome:colorShift"
        colorShiftPix.input = self as? PIX & NODEOut
        colorShiftPix.saturation = 0.0
        colorShiftPix.tintColor = tintColor
        return colorShiftPix
    }
    
}
