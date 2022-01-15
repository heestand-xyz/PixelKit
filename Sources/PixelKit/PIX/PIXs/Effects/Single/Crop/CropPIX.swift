//
//  CropPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-05.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class CropPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = CropPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleCropPIX" }
    
    // MARK: - Public Properties
    
    var resScale: CGSize { return cropFrame.size }
    
    /// Ranged 0.0 to 1.0, Origin at Bottom Left
    public var cropFrame: CGRect {
        get { CGRect(x: cropLeft, y: cropBottom, width: cropRight - cropLeft, height: cropTop - cropBottom) }
        set {
            cropLeft = newValue.minX
            cropRight = newValue.maxX
            cropBottom = newValue.minY
            cropTop = newValue.maxY
        }
    }
    /// Left is 0.0, Center is 0.5
    @LiveFloat("cropLeft", updateResolution: true) public var cropLeft: CGFloat = 0.0
    /// Right is 1.0, Center is 0.5
    @LiveFloat("cropRight", updateResolution: true) public var cropRight: CGFloat = 1.0
    /// Bottom is 0.0, Center is 0.5
    @LiveFloat("cropBottom", updateResolution: true) public var cropBottom: CGFloat = 0.0
    /// Top is 1.0, Center is 0.5
    @LiveFloat("cropTop", updateResolution: true) public var cropTop: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_cropLeft, _cropRight, _cropBottom, _cropTop]
    }
    
    public override var uniforms: [CGFloat] {
        return [cropLeft, cropRight, cropBottom, cropTop]
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
        
        cropLeft = model.cropLeft
        cropRight = model.cropRight
        cropBottom = model.cropBottom
        cropTop = model.cropTop

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.cropLeft = cropLeft
        model.cropRight = cropRight
        model.cropBottom = cropBottom
        model.cropTop = cropTop

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixCrop(_ cropFrame: CGRect) -> CropPIX {
        let cropPix = CropPIX()
        cropPix.name = ":crop:"
        cropPix.input = self as? PIX & NODEOut
        cropPix.cropFrame = cropFrame
        return cropPix
    }
    
    func pixCropLeft(_ cropFraction: CGFloat) -> CropPIX {
        pixCrop(CGRect(x: cropFraction, y: 0.0, width: 1.0 - cropFraction, height: 1.0))
    }
    
    func pixCropRight(_ cropFraction: CGFloat) -> CropPIX {
        pixCrop(CGRect(x: 0.0, y: 0.0, width: 1.0 - cropFraction, height: 1.0))
    }
    
    func pixCropTop(_ cropFraction: CGFloat) -> CropPIX {
        pixCrop(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0 - cropFraction))
    }
    
    func pixCropBottom(_ cropFraction: CGFloat) -> CropPIX {
        pixCrop(CGRect(x: 0.0, y: cropFraction, width: 1.0, height: 1.0 - cropFraction))
    }
    
}
