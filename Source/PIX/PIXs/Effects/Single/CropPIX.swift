//
//  CropPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-05.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

final public class CropPIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectSingleCropPIX" }
    
    public var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    var resScale: CGSize { return cropFrame.size }
    
    public var cropFrame: CGRect {
        get { CGRect(x: cropLeft, y: cropBottom, width: cropRight - cropLeft, height: cropTop - cropBottom) }
        set {
            cropLeft = newValue.minX
            cropRight = newValue.maxX
            cropBottom = newValue.minY
            cropTop = newValue.maxY
        }
    }
    @LiveResolution public var cropLeft: CGFloat = 0.0
    @LiveResolution public var cropRight: CGFloat = 1.0
    @LiveResolution public var cropBottom: CGFloat = 0.0
    @LiveResolution public var cropTop: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_cropLeft, _cropRight, _cropBottom, _cropTop]
    }
    
    public override var uniforms: [CGFloat] {
        return [cropLeft, cropRight, cropBottom, cropTop]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Crop", typeName: "pix-effect-single-crop")
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
